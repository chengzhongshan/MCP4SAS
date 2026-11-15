# Intermittent macOS Python workflow failure

The failed [Python 3.13 macOS job](https://github.com/chengzhongshan/MCP4SAS/actions/runs/43721637484/job/132834694378)
installed Python, imported SASPy and the MCP SDK, and passed the package unit
tests. Its root regression suite then failed only `test_github_sync.py`.
This was a Git synchronization preview failure after installation.

The retained test artifact shows:

```text
Preview only; no files, real index, branch history, or GitHub content were changed.
update_github_upload.sh: line 222: echo: write error: Interrupted system call
```

The immediately preceding `read` obtained a single output line through Bash
process substitution, allowing the `git rev-list` child to finish asynchronously
while Bash printed the summary. That overlap is consistent with a late child
signal interrupting the macOS system Bash output write. No kernel signal trace
was captured; the exact signal is not independently established by the log.

The script now captures `git rev-list` output synchronously, checks its exit
status through the existing `set -e`, and reads the completed result through a
here-string. It preserves the preview's original index/history protections and
does not retry or repeat commits, merges or pushes.

The regression fixture deliberately delays the child after it writes the count
and rejects a preview printed before child completion. Before the fix this
failed locally with `FAIL: preview printed before rev-list child completed`.
After the fix the complete Git-sync integration test passed: preview/index
protection, credential/generated-file exclusions, pull-only edit restoration,
divergent-history merging, and conflict handling. This reproduces the completion
race on Windows/Git Bash; it does not pretend to reproduce macOS's exact EINTR
message on Windows.

The Python workflow now runs when `update_github_upload.sh` changes, so future
sync-helper edits cannot bypass its cross-platform tests. Its artifact action
was updated from v4 to v7, consistent with the other working installation
workflows, to remove the logged deprecated Node 20 action warning.

Raw failure logs and the downloaded artifact are retained locally under
`MCP4SAS_Use_Python/test-results/macos-ci-43721637484/`.
The follow-up GitHub checks exercise the fix on macOS, Ubuntu and Windows with
Python 3.10 and 3.13. These are offline installation/runtime regressions, not
live SAS account or licensed local-SAS tests on those hosted machines.
