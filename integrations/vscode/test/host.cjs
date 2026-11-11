const vscode = require('vscode');
const assert = require('node:assert/strict');
const cp = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
exports.run = async () => {
  const extension = vscode.extensions.getExtension('chengzhongshan.mcp4sas');
  assert.ok(extension);
  const api = await extension.activate();
  const commands = await vscode.commands.getCommands(true);
  for (const name of ['setup', 'connect', 'check', 'help']) assert.ok(commands.includes(`mcp4sas.${name}`));
  assert.deepEqual(api.provider.provideMcpServerDefinitions(), []);
  const pick = vscode.window.showQuickPick;
  const info = vscode.window.showInformationMessage;
  try {
    fs.mkdirSync(path.dirname(api.configFile()), { recursive: true });
    fs.writeFileSync(api.configFile(), JSON.stringify({ repo: path.resolve(__dirname, '../../..'), perl: 'test-only-perl', cwd: __dirname }));
    vscode.window.showQuickPick = async () => [{ label: 'GitHub Copilot' }];
    vscode.window.showInformationMessage = async () => undefined;
    await vscode.commands.executeCommand('mcp4sas.connect');
    const servers = api.provider.provideMcpServerDefinitions();
    assert.equal(servers.length, 1);
    assert.ok(servers[0] instanceof vscode.McpStdioServerDefinition);
    assert.equal(servers[0].command, process.execPath);
    assert.deepEqual(servers[0].args, api.launchSettings().args);
    assert.equal(servers[0].env.ELECTRON_RUN_AS_NODE, '1');
    assert.equal(servers[0].cwd.fsPath, __dirname);
    assert.equal(servers[0].version, require('../package.json').version);
  } finally {
    vscode.window.showQuickPick = pick;
    vscode.window.showInformationMessage = info;
    fs.rmSync(api.configFile(), { force: true });
  }
  const result = cp.spawnSync(process.execPath, ['-e', 'process.stdout.write("electron-node-ok")'], { env: { ...process.env, ELECTRON_RUN_AS_NODE: '1' }, windowsHide: true, encoding: 'utf8' });
  assert.equal(result.status, 0); assert.equal(result.stdout, 'electron-node-ok');
  console.log('PASS: real VS Code activation, four commands, empty/configured MCP provider, Copilot connection, Electron Node launcher');
};
