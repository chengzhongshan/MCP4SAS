#!/usr/bin/env bash
set -euo pipefail

# Run from anywhere: bash update_github_upload.sh "Describe the change"
# Download updates only: bash update_github_upload.sh --pull-only
# Preview without changing the real Git index: bash update_github_upload.sh --dry-run

usage() {
  cat <<'USAGE'
Usage: bash update_github_upload.sh [--dry-run] [--pull-only] ["commit message"]

Fetches GitHub updates, commits eligible local source/documentation edits,
merges remote changes, and pushes the combined history. Run with no local
edits to download updates from another computer. Never force-pushes.
--pull-only downloads/merges updates without committing or pushing local edits.
--dry-run previews using the last fetched remote state; it does not contact
GitHub or change your files, branches, or real Git index.
Credentials, local dependencies, and SAS run artifacts remain excluded from new commits.
Local tracked edits are saved temporarily when a merge needs a clean tree.
Conflicts stop synchronization before any push and keep saved edits in Git.
REMOTE_NAME and BRANCH_NAME can override the default origin/main destination.
USAGE
}

is_generated_file() {
  local path="$1"
  case "$path" in
    .venv*/*|local/*|cache/*|tmp*/*|SAS_Output*/*|.git/*|\
    sas_submit_worker_*|sas_action_runner_*|sas_action_args_*|\
    sas_action_result_*|sas_submit_result_*|*/__pycache__/*)
      return 0 ;;
  esac
  case "${path##*/}" in
    sascfg_personal.py|.authinfo|_authinfo|.netrc|.env|.env.*|\
    *.pem|*.key|*.pyc|*.log|*.status.json|*.info.txt|\
    *.sas7bdat|*.sas7bcat|*.zip|*.gz|*.pid|*.request.md5)
      return 0 ;;
  esac
  return 1
}

is_new_source_file() {
  local path="$1"
  is_generated_file "$path" && return 1
  case "${path##*/}" in
    .gitignore|.gitattributes|Makefile|cpanfile|Vagrantfile|*.pl|*.pm|*.sh|*.sas|*.py|*.R|*.Rmd|\
    *.md|*.txt|*.json|*.yaml|*.yml|*.toml|*.ini|*.cfg|*.sql|\
    *.js|*.ts|*.ipynb)
      return 0 ;;
  esac
  return 1
}

stage_source_changes() {
  local path
  # New data/run files are not staged merely because they are in the workspace.
  git add -u -- .
  while IFS= read -r -d '' path; do
    if is_new_source_file "$path"; then
      git add -- "$path"
    fi
  done < <(git ls-files --others --exclude-standard -z)

  # Unstage generated files, including manually staged or previously tracked ones.
  excluded_count=0
  while IFS= read -r -d '' path; do
    if is_generated_file "$path"; then
      git restore --staged -- "$path"
      (( excluded_count += 1 ))
    fi
  done < <(git diff --cached --name-only --no-renames -z)
  echo "Generated files kept out of commit: $excluded_count"
  git -c core.whitespace=cr-at-eol diff --cached --check
  if git diff --cached --quiet; then
    echo 'No new source or documentation edits to commit.'
  else
    echo 'Files to commit:'
    git diff --cached --name-status
  fi
}

restore_saved_edits() {
  local saved_oid="$1" stash_ref stash_oid
  [[ -n "$saved_oid" ]] || return 0
  if ! git stash apply --index "$saved_oid"; then
    echo 'Synchronization stopped: saved local edits conflict with the downloaded changes.' >&2
    echo "Your edits remain in stash $saved_oid. Review 'git status', resolve the files, then rerun this script." >&2
    return 1
  fi
  # Drop only the stash we created; retain any earlier user stashes.
  while read -r stash_ref stash_oid; do
    if [[ "$stash_oid" == "$saved_oid" ]]; then
      git stash drop "$stash_ref" || return 1
      return 0
    fi
  done < <(git stash list --format='%gd %H')
}

integrate_remote_changes() {
  local saved_oid=''
  if git merge-base --is-ancestor "$remote_ref" HEAD; then
    return 0
  fi
  if ! git diff HEAD --quiet; then
    # Save tracked edits only: untracked/ignored data and run outputs stay on disk.
    git stash push -m "MCP4SAS synchronization saved edits $(date -u +%Y%m%dT%H%M%SZ)"
    saved_oid="$(git rev-parse refs/stash)"
    echo "Saved local tracked edits in stash $saved_oid."
  fi
  if ! git -c merge.autoStash=false merge --ff --no-edit "$remote_ref"; then
    echo 'Synchronization stopped before pushing. Git could not merge the remote changes.' >&2
    if git rev-parse --verify -q MERGE_HEAD >/dev/null; then
      echo "Review 'git status', resolve conflicts, and run 'git add <resolved files>' followed by 'git commit'." >&2
      if [[ -n "$saved_oid" ]]; then
        echo "After resolving the merge, restore your saved edits with: git stash apply --index $saved_oid" >&2
      fi
    else
      restore_saved_edits "$saved_oid" || return 1
      echo 'Local files were preserved. Review the Git error above and rerun after fixing it.' >&2
    fi
    return 1
  fi
  restore_saved_edits "$saved_oid"
}

main() {
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  cd "$ROOT_DIR"
  REMOTE_NAME="${REMOTE_NAME:-origin}"
  BRANCH_NAME="${BRANCH_NAME:-main}"
  COMMIT_MSG='Update MCP4SAS scripts'
  DRY_RUN=0
  PULL_ONLY=0
  MESSAGE_SET=0
  local arg operation
  for arg in "$@"; do
    case "$arg" in
      --dry-run) DRY_RUN=1 ;;
      --pull-only|--sync-only) PULL_ONLY=1 ;;
      -h|--help) usage; return 0 ;;
      --*) echo "Unknown option: $arg" >&2; usage >&2; return 2 ;;
      *)
        if (( MESSAGE_SET )); then
          echo 'Provide the commit message as one quoted argument.' >&2
          return 2
        fi
        COMMIT_MSG="$arg"
        MESSAGE_SET=1
        ;;
    esac
  done
  [[ -n "$COMMIT_MSG" ]] || { echo 'Commit message cannot be empty.' >&2; return 2; }
  if (( PULL_ONLY && MESSAGE_SET )); then
    echo '--pull-only does not create a commit; omit the commit message.' >&2
    return 2
  fi
  git rev-parse --is-inside-work-tree >/dev/null
  [[ -z "$(git rev-parse --show-prefix)" ]] || {
    echo "The script must live at the Git repository root: $ROOT_DIR" >&2
    return 2
  }
  current_branch="$(git symbolic-ref --quiet --short HEAD)" || {
    echo 'Cannot synchronize from a detached HEAD.' >&2
    return 2
  }
  [[ "$current_branch" == "$BRANCH_NAME" ]] || {
    echo "Current branch is $current_branch; expected $BRANCH_NAME. Set BRANCH_NAME explicitly if intended." >&2
    return 2
  }
  for operation in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply; do
    if [[ -e "$(git rev-parse --git-path "$operation")" ]]; then
      echo "Finish or abort the existing Git operation ($operation) before synchronizing." >&2
      return 1
    fi
  done
  [[ -z "$(git ls-files --unmerged)" ]] || {
    echo "Resolve the conflicts shown by 'git status' before synchronizing." >&2
    return 1
  }
  git remote get-url "$REMOTE_NAME" >/dev/null
  remote_ref="refs/remotes/$REMOTE_NAME/$BRANCH_NAME"
  echo "Repository: $ROOT_DIR"
  echo "Synchronizing with: $REMOTE_NAME/$BRANCH_NAME"
  if (( DRY_RUN )); then
    echo 'Remote comparison uses the last fetched state; newer GitHub updates may exist.'
    if (( ! PULL_ONLY )); then
      index_path="$(git rev-parse --git-path index)"
      preview_index="$(mktemp "${TMPDIR:-/tmp}/mcp4sas-index.XXXXXXXX")"
      if [[ -f "$index_path" ]]; then
        cp "$index_path" "$preview_index"
      else
        rm -f -- "$preview_index"
      fi
      # Native Windows Git does not understand Cygwin /tmp paths in env vars.
      export GIT_INDEX_FILE="$preview_index"
      if [[ "$(uname -s)" == CYGWIN* ]] && [[ "$(git --version)" == *windows* ]]; then
        GIT_INDEX_FILE="$(cygpath -m "$preview_index")"
      fi
      [[ -f "$preview_index" ]] || git read-tree HEAD
      trap 'rm -f -- "$preview_index"' EXIT
    fi
  else
    git fetch "$REMOTE_NAME" "refs/heads/$BRANCH_NAME:$remote_ref"
    git show-ref --verify --quiet "$remote_ref" || {
      echo "Cannot find $remote_ref after fetch." >&2
      return 1
    }
    git merge-base HEAD "$remote_ref" >/dev/null || {
      echo 'Local and remote histories are unrelated; synchronization stopped.' >&2
      return 1
    }
  fi

  if (( ! PULL_ONLY )); then
    stage_source_changes
  fi
  if (( DRY_RUN )); then
    if git show-ref --verify --quiet "$remote_ref"; then
      read -r local_ahead remote_ahead < <(git rev-list --left-right --count HEAD..."$remote_ref")
      echo "Existing commits: $local_ahead local-only, $remote_ahead remote-only."
    fi
    echo 'Preview only; no files, real index, branch history, or GitHub content were changed.'
    return 0
  fi
  if (( ! PULL_ONLY )) && ! git diff --cached --quiet; then
    git commit -m "$COMMIT_MSG"
  fi
  integrate_remote_changes
  if (( PULL_ONLY )); then
    echo 'Downloaded and integrated remote updates. Local edits and local-only commits were retained; nothing was pushed.'
  elif [[ "$(git rev-parse HEAD)" == "$(git rev-parse "$remote_ref")" ]]; then
    echo 'Local branch and remote branch are synchronized; no push is needed.'
  else
    if ! git push "$REMOTE_NAME" "HEAD:refs/heads/$BRANCH_NAME"; then
      echo 'Push failed; local commits are retained. If another computer updated GitHub meanwhile, rerun this script to fetch and merge its updates.' >&2
      return 1
    fi
    echo "Local and online source copies synchronized at $REMOTE_NAME/$BRANCH_NAME."
  fi
}

# Parse the complete function before running: pulling an updated copy of this
# script while it runs must not change the commands of the current invocation.
main "$@"; exit $?
