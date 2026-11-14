const path = require('node:path');
const fs = require('node:fs');
const os = require('node:os');
const { runTests, downloadAndUnzipVSCode } = require('@vscode/test-electron');
const { hostExecutable } = require('./host-executable.cjs');
const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-vscode-test-'));
const workspace = path.join(profile, "Reader's SAS project");
fs.mkdirSync(workspace);
delete process.env.ELECTRON_RUN_AS_NODE; // Agent shells may inherit this; the test host must launch the editor.
(async () => {
  const executable = process.env.VSCODE_EXECUTABLE || await downloadAndUnzipVSCode();
  // test-electron launches through cmd.exe on Windows; keep this controlled test path together.
  const workspaceArg = process.platform === 'win32' ? `"${workspace}"` : workspace;
  await runTests({ vscodeExecutablePath: hostExecutable(executable), extensionDevelopmentPath: path.resolve(__dirname, '..'), extensionTestsPath: path.join(__dirname, 'host.cjs'), launchArgs: [workspaceArg, '--user-data-dir', profile, '--extensions-dir', path.join(profile, 'extensions'), '--disable-workspace-trust', '--skip-welcome', '--skip-release-notes'] });
})().catch(e => { console.error(e); process.exitCode = 1; });
