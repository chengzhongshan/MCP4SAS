'use strict';
const vscode = require('vscode');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const core = require('./core');
const VERSION = require('../package.json').version;
const { spawn } = require('node:child_process');
let context, output, emitter;
const configFile = () => path.join(context.globalStorageUri.fsPath, 'runtime.json');
const readConfig = () => fs.existsSync(configFile()) ? JSON.parse(fs.readFileSync(configFile(), 'utf8')) : null;
function trusted() {
  if (!vscode.workspace.isTrusted) throw new Error('Trust your own project before configuring SAS tools.');
  if (vscode.env.remoteName) throw new Error('Quick Setup currently supports local desktop folders. Open a local folder; SSH/WSL/container setup is separate.');
}
async function folder(label, defaultPath) {
  const selected = await vscode.window.showOpenDialog({ title: label, canSelectFiles: false, canSelectFolders: true, canSelectMany: false, defaultUri: defaultPath ? vscode.Uri.file(defaultPath) : undefined });
  return selected?.[0].fsPath;
}
async function findPerl() {
  let candidates;
  if (process.platform === 'win32') {
    const roots = ['C:\\cygwin64', 'C:\\cygwin', path.join(process.env.LOCALAPPDATA || os.homedir(), 'MCP4SAS', 'cygwin')];
    candidates = roots.map(p => path.join(p, 'bin', 'perl.exe'));
  } else candidates = ['/opt/homebrew/opt/perl/bin/perl', '/usr/local/opt/perl/bin/perl', '/usr/bin/perl'];
  for (const candidate of candidates) if (fs.existsSync(candidate) && (process.platform !== 'win32' || fs.existsSync(path.join(path.dirname(candidate), 'cygpath.exe')))) return candidate;
  return null;
}
async function choosePerl() {
  const detected = await findPerl();
  if (detected) return detected;
  const selected = await vscode.window.showOpenDialog({ title: process.platform === 'win32' ? 'Choose Cygwin bin/perl.exe (not Strawberry Perl)' : 'Choose the Perl used by MCP4SAS', canSelectFiles: true, canSelectFolders: false, canSelectMany: false });
  const perl = selected?.[0].fsPath;
  if (perl && process.platform === 'win32' && !fs.existsSync(path.join(path.dirname(perl), 'cygpath.exe'))) throw new Error('Choose Perl from the Cygwin installation containing cygpath.exe.');
  return perl;
}
async function task(command, args, cwd, env = {}) {
  const definition = { type: 'mcp4sas-setup', nonce: String(Date.now()) };
  // Pass native executable paths directly to VS Code, independent of the
  // user's default terminal shell (Cygwin interprets Windows backslashes).
  const execution = new vscode.ProcessExecution(command, args, { cwd, env });
  const t = new vscode.Task(definition, vscode.TaskScope.Global, 'MCP4SAS installer', 'MCP4SAS', execution);
  t.presentationOptions = { reveal: vscode.TaskRevealKind.Always, panel: vscode.TaskPanelKind.Dedicated, focus: true };
  return new Promise((resolve, reject) => {
    const subscription = vscode.tasks.onDidEndTaskProcess(event => {
      if (event.execution.task.definition.nonce !== definition.nonce) return;
      subscription.dispose();
      if (event.exitCode === 0) resolve(); else reject(new Error('Installer did not finish successfully. Read the installer terminal, fix its reported prerequisite, then run Quick Setup again.'));
    });
    vscode.tasks.executeTask(t).catch(e => { subscription.dispose(); reject(e); });
  });
}
async function bootstrapCygwin() {
  const root = path.join(process.env.LOCALAPPDATA || os.homedir(), 'MCP4SAS', 'cygwin');
  const cache = path.join(context.globalStorageUri.fsPath, 'downloads');
  fs.mkdirSync(cache, { recursive: true });
  const setup = path.join(cache, 'setup-x86_64.exe');
  await vscode.window.withProgress({ location: vscode.ProgressLocation.Notification, title: 'Downloading official Cygwin setup' }, async () => {
    const response = await fetch('https://cygwin.com/setup-x86_64.exe');
    if (!response.ok) throw new Error(`Cygwin download failed: HTTP ${response.status}`);
    fs.writeFileSync(setup, Buffer.from(await response.arrayBuffer()));
  });
  output.appendLine('Installing a per-user Cygwin environment. Package downloads may take several minutes.'); output.show(true);
  // setup runs hidden; progress is reported here. No shell-built command or elevation.
  await new Promise((resolve, reject) => {
    const p = spawn(setup, ['-q', '-B', '-n', '-N', '-d', '--no-write-registry', '-R', root, '-l', path.join(cache, 'packages'), '-s', 'https://mirrors.kernel.org/sourceware/cygwin/', '-P', 'bash,git,curl,perl,ca-certificates'], { windowsHide: true, env: core.cygwinEnvironment(path.join(root, 'bin', 'perl.exe')) });
    p.on('error', reject); p.stdout?.on('data', b => output.append(b.toString())); p.stderr?.on('data', b => output.append(b.toString()));
    p.on('close', code => code === 0 ? resolve() : reject(new Error(`Cygwin setup returned ${code}. Inspect ${root}/var/log/setup.log, then retry.`)));
  });
  return path.join(root, 'bin', 'perl.exe');
}
function windowsJava() {
  const candidates = [process.env.SASPY_JAVA_WIN, process.env.SASPY_JAVA, process.env.JAVA_HOME && path.join(process.env.JAVA_HOME, 'bin', 'java.exe')];
  for (const vendor of ['Microsoft', 'Eclipse Adoptium', 'Java']) {
    const parent = path.join(process.env.ProgramFiles || 'C:\\Program Files', vendor);
    if (fs.existsSync(parent)) for (const dir of fs.readdirSync(parent)) candidates.push(path.join(parent, dir, 'bin', 'java.exe'));
  }
  return candidates.find(p => p && fs.existsSync(p));
}
async function ensureWindowsJava() {
  let java = windowsJava();
  if (java) return java;
  const choice = await vscode.window.showQuickPick(['Install Microsoft OpenJDK 21 with winget', 'Choose an installed Windows java.exe'], { title: 'SASPy needs Windows Java' });
  if (!choice) throw new Error('Java setup cancelled; rerun Quick Setup when ready.');
  if (choice.startsWith('Install')) {
    await task('winget', ['install', '--id', 'Microsoft.OpenJDK.21', '--exact', '--silent', '--accept-package-agreements', '--accept-source-agreements'], os.homedir());
    java = windowsJava();
  }
  if (!java) {
    const selected = await vscode.window.showOpenDialog({ title: 'Choose the Windows Java bin/java.exe', canSelectFiles: true, canSelectFolders: false, canSelectMany: false });
    java = selected?.[0].fsPath;
  }
  if (!java) throw new Error('Windows Java was not selected. Complete Java installation and retry.');
  return java;
}
async function installNew() {
  const workspaces = vscode.workspace.workspaceFolders || [];
  if (!workspaces.length) throw new Error('Open the folder where you want MCP4SAS scripts installed, then rerun Quick Setup.');
  const workspace = workspaces.length === 1 ? workspaces[0] : await vscode.window.showWorkspaceFolderPick({ placeHolder: 'Choose the open folder for MCP4SAS scripts' });
  if (!workspace) return;
  const repo = workspace.uri.fsPath;
  let perl = await findPerl();
  if (process.platform === 'win32' && !perl) {
    const choice = await vscode.window.showQuickPick(['Install Cygwin for me', 'Choose an existing Cygwin Perl'], { title: 'Windows requires Cygwin before MCP4SAS' });
    if (!choice) return;
    perl = choice.startsWith('Install') ? await bootstrapCygwin() : await choosePerl();
    if (!perl) return;
  }
  const java = process.platform === 'win32' ? await ensureWindowsJava() : undefined;
  const install = core.platformInstaller(process.platform);
  fs.mkdirSync(context.globalStorageUri.fsPath, { recursive: true });
  if (fs.existsSync(path.join(repo, 'server.pl'))) {
    core.assertRepo(repo); // Never reset/pull an existing checkout silently.
    output.appendLine(`Using existing MCP4SAS source: ${repo}`);
  } else {
    const git = process.platform === 'win32' ? path.join(path.dirname(perl), 'git.exe') : 'git';
    if (process.platform === 'linux') {
      try { await core.run(git, ['--version']); }
      catch { await task('/bin/bash', ['-c', 'sudo apt-get update\nsudo apt-get install -y git'], os.homedir()); }
    }
    const staging = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-source-'));
    try {
      const source = path.join(staging, 'source');
      await vscode.window.withProgress({ location: vscode.ProgressLocation.Notification, title: `Downloading MCP4SAS scripts into ${repo}` }, () => core.run(git, ['clone', '--depth', '1', 'https://github.com/chengzhongshan/MCP4SAS.git', source], { timeout: 300000, ...(process.platform === 'win32' ? { env: core.cygwinEnvironment(perl) } : {}) }));
      core.installSourceFiles(source, repo);
    } finally {
      if (path.dirname(path.resolve(staging)) === path.resolve(os.tmpdir()) && path.basename(staging).startsWith('mcp4sas-source-')) fs.rmSync(staging, { recursive: true, force: true });
    }
  }
  core.assertRepo(repo);
  output.appendLine(`MCP4SAS source and Perl runner available at: ${repo}`);
  const bash = process.platform === 'win32' ? path.join(path.dirname(perl), 'bash.exe') : '/bin/bash';
  const script = process.platform === 'win32' ? await core.toPosix(path.join(repo, 'install', install), perl) : path.join(repo, 'install', install);
  await task(bash, ['--noprofile', '--norc', script], repo, { ...(process.platform === 'win32' ? core.cygwinEnvironment(perl) : {}), ...(java ? { SASPY_JAVA_WIN: java } : {}) });
  // macOS installer may install Homebrew Perl for the first time.
  perl = core.installedPerl(await findPerl(), perl);
  return { repo, perl, java, cwd: repo };
}
async function saveRuntime(runtime) {
  if (!runtime?.perl) throw new Error('A Perl executable is required.');
  core.assertRepo(runtime.repo);
  const cwd = runtime.cwd || await folder('Choose your local SAS project folder (used for relative file and macro discovery)', vscode.workspace.workspaceFolders?.[0]?.uri.fsPath);
  if (!cwd) return false;
  fs.mkdirSync(context.globalStorageUri.fsPath, { recursive: true });
  // Stable copies survive extension versioned directory changes.
  refreshLauncher();
  core.writePrivate(configFile(), JSON.stringify({ repo: runtime.repo, perl: runtime.perl, cwd, ...(runtime.java ? { java: runtime.java } : {}) }, null, 2) + '\n');
  await configureCygwinTerminal(runtime.perl);
  output.appendLine(`MCP4SAS source/runtime folder: ${runtime.repo}`);
  output.appendLine(`SAS project folder (data and macros): ${cwd}`);
  output.appendLine('For manual SAS submissions, run MCP4SAS: Open MCP4SAS Runtime Terminal.');
  const action = await vscode.window.showInformationMessage(`MCP4SAS scripts are installed in ${runtime.repo}. Your SAS project is ${cwd}.`, 'Open Runtime Terminal');
  if (action === 'Open Runtime Terminal') await openRuntimeTerminal();
  emitter.fire(); return true;
}
async function openRuntimeTerminal() {
  trusted(); const config = readConfig(); if (!config) return setup();
  core.assertRepo(config.repo);
  const env = await core.runtimeEnvironment(config);
  if (process.platform !== 'win32') env.PATH = path.dirname(config.perl) + path.delimiter + (env.PATH || '');
  const terminal = vscode.window.createTerminal({
    name: 'MCP4SAS Runtime', cwd: config.repo, env,
    shellPath: process.platform === 'win32' ? path.join(path.dirname(config.perl), 'bash.exe') : '/bin/bash',
    shellArgs: ['--login', '-i']
  });
  terminal.show();
  output.appendLine(`Manual command from this terminal: perl run_sas_codes_or_files_in_ODA.pl --code 'proc print data=sashelp.class; run;'`);
}
async function configureCygwinTerminal(perl, explicit = false) {
  if (process.platform !== 'win32' || vscode.env.remoteName) return;
  if (!explicit && !vscode.workspace.getConfiguration('mcp4sas').get('configureCygwinTerminal', true)) return;
  const bash = path.join(path.dirname(perl), 'bash.exe');
  if (!fs.existsSync(bash) || !fs.existsSync(path.join(path.dirname(perl), 'cygpath.exe'))) throw new Error('Cygwin bash.exe and cygpath.exe must be installed alongside Perl before configuring the terminal.');
  const terminal = vscode.workspace.getConfiguration('terminal.integrated');
  const name = 'MCP4SAS Cygwin';
  const profiles = terminal.inspect('profiles.windows')?.globalValue || {};
  await terminal.update('profiles.windows', { ...profiles, [name]: { path: bash, args: ['--login', '-i'], env: { CHERE_INVOKING: '1' }, icon: 'terminal-bash' } }, vscode.ConfigurationTarget.Global);
  if (explicit || !context.globalState.get('cygwinTerminalConfigured')) {
    await terminal.update('defaultProfile.windows', name, vscode.ConfigurationTarget.Global);
    await context.globalState.update('cygwinTerminalConfigured', true);
    output.appendLine('Cygwin is now the default for new VS Code terminals. Use Terminal: Select Default Profile to change it later. Existing terminals keep their current shell.');
  }
}
async function useCygwinTerminal() {
  trusted();
  if (process.platform !== 'win32') throw new Error('The Cygwin terminal profile is available on local Windows only.');
  const perl = readConfig()?.perl || await choosePerl();
  if (perl) await configureCygwinTerminal(perl, true);
}
function refreshLauncher() {
  fs.mkdirSync(context.globalStorageUri.fsPath, { recursive: true });
  for (const name of ['relay.js', 'core.js']) core.writePrivate(path.join(context.globalStorageUri.fsPath, name), fs.readFileSync(path.join(context.extensionPath, 'src', name)));
}
async function setup() {
  trusted();
  const route = await vscode.window.showQuickPick(['Use my existing MCP4SAS installation', 'Install MCP4SAS for this computer'], { title: 'MCP4SAS Quick Setup' });
  if (!route) return;
  let runtime;
  if (route.startsWith('Use')) {
    const repo = await folder('Choose the folder containing MCP4SAS server.pl', readConfig()?.repo);
    if (!repo) return;
    core.assertRepo(repo); const perl = await choosePerl(); if (!perl) return;
    runtime = { repo, perl };
  } else runtime = await installNew();
  if (!runtime || !await saveRuntime(runtime)) return;
  await connect();
}
function launchSettings() {
  return core.launcher(configFile(), path.join(context.globalStorageUri.fsPath, 'relay.js'), process.execPath);
}
async function connect() {
  trusted();
  if (!readConfig()) return setup();
  const targets = await vscode.window.showQuickPick([
    { label: 'GitHub Copilot', picked: true }, { label: 'OpenAI Codex', picked: true }
  ], { canPickMany: true, title: 'Choose the assistants that should receive MCP4SAS tools' });
  if (!targets?.length) return;
  if (targets.some(t => t.label === 'OpenAI Codex')) {
    const file = path.join(process.env.CODEX_HOME || path.join(os.homedir(), '.codex'), 'config.toml');
    core.writeCodex(file, launchSettings());
    output.appendLine('Added managed mcp4sas_vscode entry to Codex config. Existing content retained; changed files backed up.');
  }
  await context.globalState.update('copilotEnabled', targets.some(t => t.label === 'GitHub Copilot'));
  emitter.fire();
  vscode.window.showInformationMessage('MCP4SAS is configured. Refresh/restart the selected assistant, allow its MCP server when prompted, then run MCP4SAS: Check Connection. SAS login still requires your private SASPy setup.');
}
async function check() {
  trusted(); const config = readConfig(); if (!config) return setup();
  output.show(true); output.appendLine('Starting an isolated discovery probe; no SAS submission yet.');
  const launch = launchSettings();
  const p = spawn(launch.command, launch.args, { windowsHide: true, env: { ...process.env, ...launch.env }, stdio: ['pipe', 'pipe', 'pipe'] });
  const rl = require('node:readline').createInterface({ input: p.stdout });
  let timer;
  try {
    const discovered = await new Promise((resolve, reject) => {
      timer = setTimeout(() => reject(new Error('Discovery timed out. Inspect the MCP4SAS output.')), 65000);
      p.on('error', reject); p.on('exit', code => reject(new Error(`Probe exited (${code}). Inspect the MCP4SAS output.`)));
      p.stderr.on('data', b => output.append(b.toString()));
      rl.on('line', line => {
        try {
          const message = JSON.parse(line);
          const reply = core.discoveryReply(message);
          if (reply?.initialize) {
            p.stdin.write(JSON.stringify({ jsonrpc: '2.0', method: 'notifications/initialized' }) + '\n');
            p.stdin.write(JSON.stringify({ jsonrpc: '2.0', id: 2, method: 'tools/list' }) + '\n');
          }
          if (reply?.tools) resolve(reply.tools);
        } catch (e) { reject(e); }
      });
      p.stdin.write(JSON.stringify({ jsonrpc: '2.0', id: 1, method: 'initialize', params: { protocolVersion: '2024-11-05', capabilities: {}, clientInfo: { name: 'mcp4sas-vscode-check', version: VERSION } } }) + '\n');
    });
    output.appendLine(`Discovery PASS: ${discovered.length} tools. SAS authentication/execution has not been tested by discovery.`);
    const prompt = 'Use MCP4SAS to run proc means data=sashelp.class n nmiss min max; var Age; run; on my configured SASPy target in a fresh session. Wait for the final result and inspect the actual SAS log. Check known ages=19, missing=0, minimum=11, maximum=16. Show the tool call and observed values; do not infer successful execution from code alone.';
    const action = await vscode.window.showInformationMessage('Tools discovered; SAS login and encryption JARs still need verification. Configure missing prerequisites before running the SAS test.', 'Copy SAS test prompt', 'Configure ODA login', 'Configure SAS JARs', 'Open setup guide');
    if (action === 'Copy SAS test prompt') await vscode.env.clipboard.writeText(prompt);
    if (action === 'Configure ODA login') await configureLogin();
    if (action === 'Configure SAS JARs') await configureJars();
    if (action === 'Open setup guide') await help();
  } finally { clearTimeout(timer); rl.close(); p.stdin.end(); }
}
async function help() { await vscode.commands.executeCommand('markdown.showPreview', vscode.Uri.file(path.join(context.extensionPath, 'README.md'))); }
async function configureLogin() {
  trusted(); const config = readConfig(); if (!config) return setup();
  core.assertRepo(config.repo);
  const env = await core.runtimeEnvironment(config);
  const runner = await core.toPosix(path.join(config.repo, 'run_sas_codes_or_files_in_ODA.pl'), config.perl);
  output.appendLine('Opening private terminal login using the selected runtime and HOME. Do not enter passwords in AI chat.');
  await task(config.perl, [runner, '--prompt-sas-oda-auth', '--check-sas-oda-login-only'], config.repo, { ...env, SASPY_CFGNAME: 'oda', SAS_ODA_AUTOLOAD_MACROS: '0' });
  vscode.window.showInformationMessage('ODA login validation completed. Retry your SAS request from the assistant.');
}
async function configureJars() {
  trusted(); const config = readConfig(); if (!config) return setup();
  const directory = await folder('Select folder containing sas.rutil.jar, sas.rutil.nls.jar and sastpj.rutil.jar (download from SAS first)');
  if (!directory) return;
  const missing = ['sas.rutil.jar', 'sas.rutil.nls.jar', 'sastpj.rutil.jar'].filter(name => {
    try { const st = fs.statSync(path.join(directory, name)); return !st.isFile() || !st.size; } catch { return true; }
  });
  if (missing.length) throw new Error(`Missing SAS encryption files: ${missing.join(', ')}. Download from https://support.sas.com/downloads/package.htm?pid=2494 using your SAS Profile, extract the archive, and select the directory directly containing all three files. Then rerun MCP4SAS: Configure SAS Encryption JARs.`);
  const env = await core.runtimeEnvironment(config);
  const script = await core.toPosix(path.join(config.repo, 'install', 'install_saspy_iom_jars.sh'), config.perl);
  const bash = process.platform === 'win32' ? path.join(path.dirname(config.perl), 'bash.exe') : '/bin/bash';
  const jarDirectory = await core.toPosix(directory, config.perl);
  await task(bash, ['--noprofile', '--norc', script], config.repo, { ...env, MCP4SAS_SASPY_IOM_DIR: jarDirectory });
  vscode.window.showInformationMessage('SAS JAR helper completed for the installer environment. Custom SASPy configurations must reference these files too. Restart the assistant connection and use a fresh SAS session before retrying.');
}
async function activate(ctx) {
  context = ctx; output = vscode.window.createOutputChannel('MCP4SAS'); emitter = new vscode.EventEmitter();
  if (vscode.workspace.isTrusted && !vscode.env.remoteName && fs.existsSync(configFile())) refreshLauncher();
  context.subscriptions.push(output, emitter);
  for (const [id, fn] of Object.entries({ setup, connect, check, help, configureLogin, configureJars, openRuntimeTerminal, cygwinTerminal: useCygwinTerminal })) context.subscriptions.push(vscode.commands.registerCommand(`mcp4sas.${id}`, async () => { try { await fn(); } catch (e) { output.appendLine(e.message); output.show(true); vscode.window.showErrorMessage(`MCP4SAS: ${e.message}`); } }));
  const provider = {
    onDidChangeMcpServerDefinitions: emitter.event,
    provideMcpServerDefinitions() {
      if (!vscode.workspace.isTrusted || vscode.env.remoteName || !context.globalState.get('copilotEnabled') || !readConfig()) return [];
      const launch = launchSettings();
      const server = new vscode.McpStdioServerDefinition('MCP4SAS', launch.command, launch.args, launch.env, VERSION);
      server.cwd = vscode.Uri.file(readConfig().cwd);
      return [server];
    },
    resolveMcpServerDefinition(server) { trusted(); return server; }
  };
  context.subscriptions.push(vscode.lm.registerMcpServerDefinitionProvider('mcp4sas.local', provider));
  if (process.platform === 'win32' && vscode.workspace.isTrusted && !vscode.env.remoteName) {
    try {
      const perl = readConfig()?.perl || await findPerl();
      if (perl) await configureCygwinTerminal(perl);
    } catch (e) { output.appendLine(`Cygwin terminal setup: ${e.message}`); }
  }
  return { provider, configFile, launchSettings, configureCygwinTerminal }; // Also exercised by extension-host tests.
}
module.exports = { activate };
