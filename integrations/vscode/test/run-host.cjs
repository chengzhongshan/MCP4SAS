const path = require('node:path');
const fs = require('node:fs');
const os = require('node:os');
const { runTests } = require('@vscode/test-electron');
const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-vscode-test-'));
delete process.env.ELECTRON_RUN_AS_NODE; // Agent shells may inherit this; the test host must launch the editor.
runTests({ vscodeExecutablePath: process.env.VSCODE_EXECUTABLE, extensionDevelopmentPath: path.resolve(__dirname, '..'), extensionTestsPath: path.join(__dirname, 'host.cjs'), launchArgs: ['--user-data-dir', profile, '--extensions-dir', path.join(profile, 'extensions'), '--disable-workspace-trust', '--skip-welcome', '--skip-release-notes'] }).catch(e => { console.error(e); process.exitCode = 1; });
