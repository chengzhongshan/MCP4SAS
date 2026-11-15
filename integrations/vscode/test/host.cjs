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
  for (const name of ['setup', 'connect', 'check', 'help', 'cygwinTerminal', 'configureLogin', 'configureJars', 'openRuntimeTerminal', 'detectSetup', 'switchSas', 'testSas']) assert.ok(commands.includes(`mcp4sas.${name}`));
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
        const project = vscode.workspace.workspaceFolders[0].uri.fsPath;
        fs.mkdirSync(path.dirname(api.configFile()), { recursive: true });
        fs.writeFileSync(api.configFile(), JSON.stringify({ repo: path.resolve(__dirname, '../../..'), perl, cwd: scratch }));
        const savedFile = path.join(project, 'editor-saved.sas');
        await vscode.workspace.fs.writeFile(vscode.Uri.file(savedFile), Buffer.from('/* saved by VS Code */\n'));
        terminal = await api.openRuntimeTerminal();
        assert.equal(vscode.workspace.getConfiguration('terminal.integrated', vscode.workspace.workspaceFolders[0].uri).get('cwd'), '${workspaceFolder}');
        const marker = path.join(scratch, 'terminal-result.txt');
        terminal.sendText(`{ printf 'MCP4SAS_CYGWIN_OK\\n'; pwd; cat editor-saved.sas; printf '/* updated by Cygwin */\\n' >> editor-saved.sas; } > ${require('../src/core').shellQuote(marker.replace(/\\/g, '/'))}`);
        const until = Date.now() + 20000;
        while ((!fs.existsSync(marker) || !fs.readFileSync(marker, 'utf8').includes('saved by VS Code') || !fs.readFileSync(savedFile, 'utf8').includes('updated by Cygwin')) && Date.now() < until) await new Promise(resolve => setTimeout(resolve, 100));
        assert.match(fs.readFileSync(marker, 'utf8'), /MCP4SAS_CYGWIN_OK/);
        assert.ok(fs.readFileSync(marker, 'utf8').includes(path.basename(project)), 'Bash starts in the open folder, not the saved runtime cwd');
        assert.match(fs.readFileSync(savedFile, 'utf8'), /updated by Cygwin/);
        console.log('PASS: real runtime terminal uses the open VS Code folder; VS Code and Cygwin read/write the same SAS file');
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
    if(process.env.MCP4SAS_LIVE_SWITCH_RUNTIME) {
      const file=process.env.MCP4SAS_LIVE_SWITCH_RUNTIME,original=fs.readFileSync(file),saved=JSON.parse(original),results=[];
      fs.mkdirSync(path.dirname(api.configFile()),{recursive:true});
      fs.writeFileSync(api.configFile(),JSON.stringify(saved));
      vscode.window.showInformationMessage=async()=>undefined;
      for(const kind of ['oda','local','oda']) {
        vscode.window.showQuickPick=async items=>items.find(item=>item.kind===kind);
        await vscode.commands.executeCommand('mcp4sas.switchSas');
        const selected=JSON.parse(fs.readFileSync(api.configFile(),'utf8'));
        assert.equal(selected.saspyCfgname==='oda',kind==='oda');
        const directory=await api.testSelectedSas();
        const log=fs.readFileSync(path.join(directory,'output.html.info.txt'),'utf8');
        assert.match(log,/^MCP4SAS_TARGET_CHECK n=19 missing=0 minimum=11 maximum=16\s*$/m);
        assert.match(log,new RegExp('^MCP4SAS_PLATFORM '+(kind==='oda'?'LIN':'WIN'),'m'));
        results.push({kind,profile:selected.saspyCfgname,directory,verified:true});
      }
      assert.deepEqual(fs.readFileSync(file),original,'real user target configuration is unchanged');
      if(process.env.MCP4SAS_LIVE_SWITCH_OUT)fs.writeFileSync(process.env.MCP4SAS_LIVE_SWITCH_OUT,JSON.stringify({results,installed_config_unchanged:true,scope:'Real VS Code command handlers and actual Windows SAS/ODA; picker selection automated, no AI model turn.'},null,2));
      console.log('PASS: real VS Code ODA/local/ODA commands and observed SAS values');
    }
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
  console.log('PASS: real VS Code activation, eleven commands, empty/configured MCP provider, Copilot connection, Electron Node launcher');
};
