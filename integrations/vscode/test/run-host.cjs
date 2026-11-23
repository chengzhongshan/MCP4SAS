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
  let extensionPath=process.env.MCP4SAS_TEST_EXTENSION_PATH||path.resolve(__dirname,'..');
  let testsPath=process.env.MCP4SAS_TEST_HOST_PATH||path.join(__dirname,'host.cjs');
  if(process.env.MCP4SAS_TEST_EXTENSION_PATH&&!process.env.MCP4SAS_TEST_HOST_PATH) {
    // VS Code attributes require('vscode') to the calling extension's path.
    // An external source-tree test gets a different API object from the
    // installed extension, so its picker stubs do not affect that extension.
    // Stage unchanged packaged files plus the harness under one test root.
    const staged=path.join(profile,'extension-under-test');
    fs.cpSync(extensionPath,staged,{recursive:true});
    fs.mkdirSync(path.join(staged,'test'),{recursive:true});
    fs.copyFileSync(testsPath,path.join(staged,'test','host.cjs'));
    extensionPath=staged;testsPath=path.join(staged,'test','host.cjs');
    process.env.MCP4SAS_TEST_RUNTIME_REPO ||= path.resolve(__dirname,'../../..');
  }
  await runTests({ vscodeExecutablePath: hostExecutable(executable), extensionDevelopmentPath: extensionPath, extensionTestsPath: testsPath, launchArgs: [workspaceArg, '--user-data-dir', profile, '--extensions-dir', path.join(profile, 'extensions'), '--disable-workspace-trust', '--skip-welcome', '--skip-release-notes'] });
})().catch(e => { console.error(e); process.exitCode = 1; });
