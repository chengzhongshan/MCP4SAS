"""Offline integration test: python tests/test_github_sync.py.

Set TEST_BASH to a Bash executable when it is not on PATH.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def run(cwd, *args, success=True):
    result = subprocess.run(args, cwd=cwd, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if (result.returncode == 0) != success:
        raise AssertionError(f"{args}: exit {result.returncode}\n{result.stdout}")
    return result.stdout.strip()


env = os.environ.copy()
for name in list(env):
    if name.startswith('GIT_') or name in ('REMOTE_NAME', 'BRANCH_NAME'):
        env.pop(name)
env.update(GIT_AUTHOR_NAME='Sync Test', GIT_AUTHOR_EMAIL='test@example.invalid',
           GIT_COMMITTER_NAME='Sync Test', GIT_COMMITTER_EMAIL='test@example.invalid',
           GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull,
           GIT_TERMINAL_PROMPT='0')
bash = os.environ.get('TEST_BASH')
if not bash and os.name=='nt':
    # PATH often resolves bash to the WSL launcher, which cannot consume native
    # Windows paths and may not have a working Linux distribution installed.
    git=shutil.which('git')
    git_bash=Path(git).resolve().parents[1]/'bin/bash.exe' if git else None
    if git_bash and git_bash.is_file():bash=str(git_bash)
bash = bash or shutil.which('bash')
assert bash, 'Bash is required'
script = Path(__file__).resolve().parents[1] / 'update_github_upload.sh'

with tempfile.TemporaryDirectory(prefix='mcp4sas-sync-') as temp:
    root = Path(temp)
    remote, first, second = (root / name for name in ('remote.git', 'first', 'second'))
    run(root, 'git', 'init', '--bare', '--initial-branch=main', str(remote))
    run(root, 'git', 'clone', str(remote), str(first))
    shutil.copyfile(script, first / script.name)
    (first / 'README.md').write_text('Initial\n')
    (first / 'notes.txt').write_text('Notes\n')
    run(first, 'git', 'add', '.')
    run(first, 'git', 'commit', '-m', 'Initial')
    run(first, 'git', 'push', '-u', 'origin', 'main')
    run(root, 'git', 'clone', str(remote), str(second))

    def sync(repo, *args, success=True):
        # Invoke outside the checkout to verify script-relative root discovery.
        return run(root, bash, (repo / script.name).as_posix(), *args, success=success)

    (first / 'helper.pl').write_text('print "hello";\n')
    (first / 'sascfg_personal.py').write_text('password = "dummy"\n')
    (first / 'SAS_Output_test').mkdir()
    (first / 'SAS_Output_test' / 'output.txt').write_text('Generated\n')
    run(first, 'git', 'add', 'sascfg_personal.py')
    before = (first / '.git' / 'index').read_bytes()
    head = run(first, 'git', 'rev-parse', 'HEAD')
    sync(first, '--dry-run')
    assert before == (first / '.git' / 'index').read_bytes()
    assert head == run(first, 'git', 'rev-parse', 'HEAD')

    # macOS's system Bash can interrupt echo when an asynchronous process
    # substitution exits. Make the rev-list child linger after writing its one
    # line: the final preview must wait for completion, not just read the line.
    delayed_git = root / 'delayed_git.sh'
    child_done = root / 'rev_list_child_done'
    delayed_git.write_text('''git() {
  if [[ "$1" == rev-list && "${2:-}" == --left-right ]]; then
    command git "$@"
    sleep 0.2
    : > "$MCP4SAS_SYNC_CHILD_DONE"
  else
    command git "$@"
  fi
}
echo() {
  if [[ "${1:-}" == Preview\\ only* && ! -f "$MCP4SAS_SYNC_CHILD_DONE" ]]; then
    builtin echo 'FAIL: preview printed before rev-list child completed' >&2
    return 1
  fi
  builtin echo "$@"
}
''', encoding='utf-8', newline='\n')
    previous_env = env.copy()
    try:
        env.update(BASH_ENV=delayed_git.as_posix(),
                   MCP4SAS_SYNC_CHILD_DONE=child_done.as_posix())
        sync(first, '--dry-run')
        assert child_done.is_file()
        assert before == (first / '.git' / 'index').read_bytes()
        assert head == run(first, 'git', 'rev-parse', 'HEAD')
    finally:
        env.clear()
        env.update(previous_env)
    print('PASS: preview waits for rev-list child completion before writing its summary')

    sync(first, 'Add helper')
    tracked = run(first, 'git', 'ls-files')
    assert 'helper.pl' in tracked
    assert 'sascfg_personal.py' not in tracked and 'SAS_Output_test' not in tracked
    assert (first / 'sascfg_personal.py').exists()
    assert run(remote, 'git', 'rev-parse', 'main') == run(first, 'git', 'rev-parse', 'HEAD')
    print('PASS: dry-run preserves index/history; push excludes credentials and outputs')

    (second / 'notes.txt').write_text('Uncommitted local notes\n')
    sync(second, '--pull-only')
    assert (second / 'helper.pl').exists()
    assert (second / 'notes.txt').read_text() == 'Uncommitted local notes\n'
    assert not run(second, 'git', 'stash', 'list')
    print('PASS: pull-only downloads updates and restores local edits')

    (first / 'first.pl').write_text('print 1;\n')
    sync(first, 'First independent edit')
    (second / 'second.pl').write_text('print 2;\n')
    sync(second, 'Second independent edit')
    assert (second / 'first.pl').exists()
    assert len(run(second, 'git', 'rev-list', '--parents', '-n', '1', 'HEAD').split()) == 3
    sync(first, '--pull-only')
    assert (first / 'second.pl').exists()
    print('PASS: divergent histories merge and synchronize both checkouts')

    (first / 'README.md').write_text('First conflicting edit\n')
    sync(first, 'First conflict edit')
    remote_head = run(remote, 'git', 'rev-parse', 'main')
    (second / 'README.md').write_text('Second conflicting edit\n')
    sync(second, 'Second conflict edit', success=False)
    assert run(second, 'git', 'ls-files', '--unmerged')
    assert remote_head == run(remote, 'git', 'rev-parse', 'main')
    print('PASS: conflicts stop before push and preserve the remote branch')
