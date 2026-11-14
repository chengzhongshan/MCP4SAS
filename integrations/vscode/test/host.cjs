const vscode = require('vscode');
const assert = require('node:assert/strict');
const cp = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
exports.run = async () => {
  const extension = vscode.extensions.getExtension('chengzhongshan.mcp4sas');
  assert.ok(extension);
  const api = await extension.activate();
  const commands = await vscode.commands.getCommands(true);
  for (const name of ['setup', 'connect', 'check', 'help', 'cygwinTerminal', 'configureLogin', 'configureJars']) assert.ok(commands.includes(`mcp4sas.${name}`));
  assert.deepEqual(api.provider.provideMcpServerDefinitions(), []);
  if (process.platform === 'win32') {
    const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-terminal-'));
    const perl = process.env.MCP4SAS_TEST_CYGWIN_PERL || path.join(scratch, 'bin', 'perl.exe');
    let terminal;
    try {
      if (!process.env.MCP4SAS_TEST_CYGWIN_PERL) {
        fs.mkdirSync(path.dirname(perl));
        for (const name of ['perl.exe', 'bash.exe', 'cygpath.exe']) fs.writeFileSync(path.join(path.dirname(perl), name), 'fixture');
      }
      await api.configureCygwinTerminal(perl, true);
      const settings = vscode.workspace.getConfiguration('terminal.integrated');
      assert.equal(settings.get('defaultProfile.windows'), 'MCP4SAS Cygwin');
      assert.equal(settings.get('profiles.windows')['MCP4SAS Cygwin'].path, path.join(path.dirname(perl), 'bash.exe'));
      if (process.env.MCP4SAS_TEST_CYGWIN_PERL) {
        // The workbench refreshes its detected profile cache asynchronously.
        await new Promise(resolve => setTimeout(resolve, 3000));
        const marker = path.join(scratch, 'terminal-result.txt');
        terminal = vscode.window.createTerminal({ name: 'MCP4SAS Cygwin smoke', cwd: scratch });
        terminal.sendText(`{ printf 'MCP4SAS_CYGWIN_OK\\n'; pwd; } > ${require('../src/core').shellQuote(marker.replace(/\\/g, '/'))}`);
        const until = Date.now() + 20000;
        while ((!fs.existsSync(marker) || !fs.readFileSync(marker, 'utf8').includes(path.basename(scratch))) && Date.now() < until) await new Promise(resolve => setTimeout(resolve, 100));
        assert.match(fs.readFileSync(marker, 'utf8'), /MCP4SAS_CYGWIN_OK/);
        assert.ok(fs.readFileSync(marker, 'utf8').includes(path.basename(scratch)), 'Bash retains the project cwd');
        console.log('PASS: actual default Cygwin terminal ran Bash and retained its project directory');
      }
    } finally {
      if (terminal) {
        await new Promise(resolve => {
          const timer = setTimeout(() => { subscription.dispose(); resolve(); }, 3000);
          const subscription = vscode.window.onDidCloseTerminal(closed => { if (closed === terminal) { clearTimeout(timer); subscription.dispose(); resolve(); } });
          terminal.dispose();
        });
      }
      await fs.promises.rm(scratch, { recursive: true, force: true, maxRetries: 10, retryDelay: 100 });
    }
  }
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
  console.log('PASS: real VS Code activation, five commands, empty/configured MCP provider, Copilot connection, Electron Node launcher');
};
