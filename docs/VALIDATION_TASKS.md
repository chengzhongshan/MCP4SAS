# MCP4SAS Validation Tasks

Run these tasks in order. Stop at the first unexplained failure, preserve its
artifacts, reduce it to a focused reproduction, and rerun the affected tier
after the fix. Live tests require a configured SAS ODA account. They do not
require Conda.

## 1. Repository And Runtime Gate

Confirm that the checkout is synchronized and free of unrelated edits:

```bash
git fetch origin
git status -sb
git diff --check
```

Install declared Perl dependencies into the repository-local library when
`local/perl5` is absent:

```bash
. install/common.sh
install_perl_deps
export PERL5LIB="$PWD/local/perl5/lib/perl5${PERL5LIB:+:$PERL5LIB}"
```

Expected evidence: all tracked Perl, shell, and Python files pass their syntax
checks. A missing declared module in an uninstalled checkout is an environment
failure, not automatically a source defect.

## 2. Complete Offline Behavior

Run every non-live `Test::More` file plus the two standalone diagnostics:

```bash
mapfile -t tests < <(
  for file in MCPDeps/test_*.pl tests/test_*.pl; do
    case "$file" in tests/test_live_*) continue;; esac
    rg -q 'use Test::More|use Test2' "$file" && printf '%s\n' "$file"
  done
)
prove "${tests[@]}"
perl MCPDeps/test_sas_oda_debug_macro_guard.pl
perl MCPDeps/test_sas_oda_connection_lifecycle.pl
python3 tests/test_github_sync.py
```

This tier covers parsing, dependency discovery, upload decisions, status and
error reporting, cleanup ownership, macro loading, and Git synchronization.

## 3. Minimal ODA Gate

Use a bounded login probe before expensive live tests:

```bash
SAS_ODA_RUN_TIMEOUT_SECONDS=120 \
  ./run_sas_codes_or_files_in_ODA.pl --check-sas-oda-login-only
```

Expected evidence: `proc setinit;run;` succeeds and the one-shot connection is
closed. A credential or network failure stops the live tier but does not
invalidate offline results.

## 4. Persistent Macro Freshness

```bash
perl tests/test_live_case_insensitive_macro_lookup.pl --live
```

Required behaviors:

- exact and case-insensitive source resolution;
- HOME and `~/Macros` precedence;
- an explicit higher-priority source refreshes a macro already compiled in the
  persistent session;
- ambiguous folded names fail without executing either source; and
- every uniquely named remote fixture is deleted and verified.

## 5. Deferred Includes And Redirected Logs

```bash
perl tests/test_live_deferred_and_printto.pl --live
perl tests/test_live_deferred_includes.pl --live
perl tests/test_live_include_file_lists.pl --live
```

Verify direct `%include`, `DOSUBL`, and `CALL EXECUTE`, including quoted paths
and multi-file include lists. A redirected SAS error must still produce a
nonzero wrapper result. For slow runs, inspect `output.run.status.json` and let
the configured timeout terminate the process tree.

## 6. Owned Remote Cleanup

```bash
perl tests/test_live_remote_directory_cleanup.pl --live
```

Only uniquely named test directories may be removed. Preview must be
non-mutating, regular files must be excluded, `_DELETE_` collisions must stop
the operation, no-match results must be explicit, and final cleanup must verify
that all owned fixtures are gone.

## 7. Acceptance And Release Evidence

Before committing:

```bash
git diff --check
git diff --cached
git status -sb
```

Accept a change only when the focused reproduction, full offline suite, and
relevant live tier pass. Record assertion counts, live artifact directories,
timeout values, cleanup verification, and any intentionally skipped tier.
