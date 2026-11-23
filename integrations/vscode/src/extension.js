'use strict';
const vscode = require('vscode');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const core = require('./core');
const discovery = require('./detect');
const nativePython = require('./native-python');
const localProfile = require('./local-profile');
const terminalTarget = require('./terminal-target');
const targetCheck = require('./target-check');
const guide = require('./setup-guide');
const timers = require('node:timers');
const VERSION = require('../package.json').version;
const { spawn } = require('node:child_process');
let context, output, emitter, targetStatus;
let setupPromise, setupPanel;
const setupStates = {};
let setupMessage = '';
function renderSetup(message = setupMessage) {
  setupMessage = message;
  if (setupPanel) setupPanel.webview.html = guide.page(setupStates, message, require('node:crypto').randomBytes(18).toString('hex'));
}
function showSetupGuide() {
  if (!vscode.window.createWebviewPanel) return; // Minimal/offline API fixtures.
  if (setupPanel) { setupPanel.reveal(); return setupPanel; }
  setupPanel = vscode.window.createWebviewPanel('mcp4sas.setupGuide','MCP4SAS Setup',vscode.ViewColumn.One,{enableScripts:true,retainContextWhenHidden:true});
  setupPanel.onDidDispose(()=>{setupPanel=undefined;});
  setupPanel.webview.onDidReceiveMessage(async message=>{
    try {
      if (message.action==='logs') return output.show(true);
      if (message.action==='watchVideo') return vscode.env.openExternal(vscode.Uri.parse(guide.VIDEO));
      if (message.action==='readGuide') return vscode.env.openExternal(vscode.Uri.parse('https://github.com/chengzhongshan/MCP4SAS/blob/main/integrations/vscode/README.md'));
      if (message.action==='downloadJars') return vscode.env.openExternal(vscode.Uri.parse(guide.SAS_DOWNLOAD));
      if (!['selectJars','login','test','continue'].includes(message.action)) return;
      trusted();
      if (setupPromise) return vscode.window.showInformationMessage('Setup is still running. Follow the progress checklist; do not start another installation.');
      const action={selectJars:configureJars,login:configureLogin,test:testSelectedSas,continue:setup}[message.action];
      await action();
    } catch(error) {renderSetup(error.message);vscode.window.showErrorMessage('MCP4SAS: '+error.message);}
  });
  renderSetup();
  return setupPanel;
}
async function setupStep(id,title,work) {
  const started=Date.now();
  setupStates[id]={status:'running',detail:title};renderSetup(title);
  return vscode.window.withProgress({location:vscode.ProgressLocation.Notification,title:'MCP4SAS: '+title,cancellable:false},async progress=>{
    const pulse=()=>{
      const message=`${guide.elapsed(started)} elapsed. ${id==='cygwin'?'Cygwin downloads can take more than five minutes. Keep the installer and VS Code open.':'Setup is still being monitored. Open the installation log for details.'}`;
      setupStates[id].detail=title+' — '+message;renderSetup(message);progress?.report({message});
    };
    pulse();const interval=timers.setInterval(pulse,10000);
    try {const result=await work();setupStates[id]={status:'complete',detail:title+' — finished in '+guide.elapsed(started)};renderSetup('Completed: '+title);return result;}
    catch(error){setupStates[id]={status:'failed',detail:error.message};renderSetup('Setup stopped at '+title+'. Fix the reported issue, then Continue Quick Setup.');throw error;}
    finally{timers.clearInterval(interval);}
  });
}
async function ensureSetupWorkspace() {
  if (vscode.env.remoteName) {trusted();return false;}
  if (vscode.workspace.workspaceFolders?.length) {
    trusted();setupStates.folder={status:'complete',detail:'Project folder is open and trusted.'};renderSetup();return true;
  }
  const choice=await vscode.window.showInformationMessage('First open the project folder where MCP4SAS scripts and your SAS programs will be saved. Select a folder you own. VS Code may ask you to trust it; setup continues after it opens.',{modal:true},'Choose Project Folder');
  if (choice!=='Choose Project Folder') return false;
  const directory=await folder('Choose your MCP4SAS project folder');if(!directory)return false;
  await core.assertWritableProject(directory,undefined,{platform:'native'});
  await context.globalState.update('pendingSetup',{folder:directory,created:Date.now()});
  await vscode.commands.executeCommand('vscode.openFolder',vscode.Uri.file(directory),false);
  return false; // Opening a folder reloads the window. Activation resumes safely.
}
const configFile = () => path.join(context.globalStorageUri.fsPath, 'runtime.json');
let configReadError;
const readConfig = () => {
  if (!fs.existsSync(configFile())) return null;
  try {
    const config=JSON.parse(fs.readFileSync(configFile(),'utf8').replace(/^\uFEFF/,''));
    if(!config||typeof config!=='object'||Array.isArray(config))throw Error('Expected a runtime configuration object');
    configReadError=undefined;return config;
  } catch(error) {
    if(configReadError!==error.message)output?.appendLine('Cannot read saved runtime: '+error.message+'. Run MCP4SAS: Quick Setup to repair it.');
    configReadError=error.message;return null;
  }
};
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
async function task(command, args, cwd, env = {}, details = {}) {
  const definition = { type: 'process', nonce: require('node:crypto').randomUUID() };
  // Pass native executable paths directly to VS Code, independent of the
  // user's default terminal shell (Cygwin interprets Windows backslashes).
  const execution = new vscode.ProcessExecution(command, args, { cwd, env });
  const t = new vscode.Task(definition, vscode.TaskScope.Global, 'MCP4SAS installer', 'MCP4SAS', execution);
  t.presentationOptions = { reveal: vscode.TaskRevealKind.Always, panel: vscode.TaskPanelKind.Dedicated, focus: true };
  return new Promise((resolve, reject) => {
    let execution;
    const early=[];
    const completed=event=>{
      // VS Code normalizes built-in process definitions and may remove custom
      // fields. Match the TaskExecution returned by executeTask, not a nonce.
      if(!execution){early.push(event);return;}
      if(event.execution!==execution)return;
      subscription.dispose();
      if (event.exitCode === 0) resolve(); else {
        let tail='';
        if(details.logFile && fs.existsSync(details.logFile))tail=fs.readFileSync(details.logFile,'utf8').split(/\r?\n/).filter(Boolean).slice(-12).join('\n');
        reject(new Error(`Installer failed (exit ${event.exitCode ?? 'unknown'}). ${details.logFile ? 'Log: '+details.logFile+'. ' : 'Read the installer terminal. '}${tail ? '\n'+tail : ''}`));
      }
    };
    const subscription = vscode.tasks.onDidEndTaskProcess(completed);
    vscode.tasks.executeTask(t).then(handle=>{execution=handle;for(const event of early)completed(event);}).catch(e => { subscription.dispose(); reject(e); });
  });
}
async function bootstrapCygwin(existingPerl, packages = 'bash,git,curl,perl,ca-certificates,gcc-core,gcc-g++,make,python3,python312,python312-devel,python312-pip,unzip,wget,zip') {
  const root = existingPerl ? path.dirname(path.dirname(existingPerl)) : path.join(process.env.LOCALAPPDATA || os.homedir(), 'MCP4SAS', 'cygwin');
  const cache = path.join(context.globalStorageUri.fsPath, 'downloads');
  fs.mkdirSync(cache, { recursive: true });
  const setup = path.join(cache, 'setup-x86_64.exe');
  await setupStep('cygwin','Prepare Cygwin — downloading the official installer',async () => {
    const response = await fetch('https://cygwin.com/setup-x86_64.exe',{signal:AbortSignal.timeout(120000)});
    if (!response.ok) throw new Error(`Cygwin download failed: HTTP ${response.status}`);
    fs.writeFileSync(setup, Buffer.from(await response.arrayBuffer()));
  output.appendLine('Installing a per-user Cygwin environment. Package downloads may take several minutes.'); output.show(true);
  renderSetup('Cygwin is installing. Its progress window and the elapsed-time notification may remain open for more than five minutes.');
  // User-facing setup: retain the official progress window as well as VS Code
  // feedback. No shell-built command, hidden GUI, or elevation is required.
  await new Promise((resolve, reject) => {
    const p = spawn(setup, ['-q', '-B', '-n', '-N', '-d', '--no-write-registry', '-R', root, '-l', path.join(cache, 'packages'), '-s', 'https://mirrors.kernel.org/sourceware/cygwin/', '-P', packages], { windowsHide: false, env: core.cygwinEnvironment(path.join(root, 'bin', 'perl.exe')) });
    p.on('error', reject); p.stdout?.on('data', b => output.append(b.toString())); p.stderr?.on('data', b => output.append(b.toString()));
    p.on('close', code => code === 0 ? resolve() : reject(new Error(`Cygwin setup returned ${code}. Inspect ${root}/var/log/setup.log, then retry.`)));
  });
  });
  return path.join(root, 'bin', 'perl.exe');
}
async function ensureCygwinPrerequisites(perl) {
  const bash=path.join(path.dirname(perl),'bash.exe'),env=core.cygwinEnvironment(perl);
  const probe=fs.readFileSync(path.join(__dirname,'cygwin_prerequisites.sh'),'utf8')+'\ncygwin_missing_prerequisites\n';
  const missing=[...new Set((await core.run(bash,['--noprofile','--norc','-c',probe],{env,timeout:30000})).split(/\s+/).filter(Boolean))];
  if(!missing.length){output.appendLine('Cygwin prerequisites already work; keeping installed packages and active sessions.');setupStates.cygwin={status:'complete',detail:'Reusing the working Cygwin installation; no package upgrades.'};renderSetup();return;}
  const state=await core.run(bash,['--noprofile','--norc','-c','printf "MCP4SAS_PROBE_PID=%s\\n" "$$"; /usr/bin/ps -l'],{env});
  const probePid=Number(state.match(/MCP4SAS_PROBE_PID=(\d+)/)?.[1]);
  const busy=state.split(/\r?\n/).map(line=>line.match(/^\s*(?:[A-Z]\s+)?(\d+)\s+(\d+)\s+\d+\s+\d+\s/)).filter(m=>m&&Number(m[1])!==probePid&&Number(m[2])!==probePid);
  if(busy.length)throw new Error(`Cygwin needs these packages: ${missing.join(', ')}. Close Cygwin terminals and stop their running jobs, then retry Quick Setup. Setup will not terminate your processes to replace DLLs.`);
  await bootstrapCygwin(perl,missing.join(','));
  const remaining=await core.run(bash,['--noprofile','--norc','-c',probe],{env,timeout:30000});
  if(remaining.trim())throw new Error('Cygwin prerequisite check still failed: '+remaining);
}
async function prepareCygwinTrust(perl) {
  const cygwinRoot = path.dirname(path.dirname(perl));
  const trustDir = path.join(context.globalStorageUri.fsPath, 'trust');
  const bundle = path.join(trustDir, 'windows-cygwin-ca-bundle.pem');
  const baseBundle = path.join(cygwinRoot, 'etc', 'pki', 'ca-trust', 'extracted', 'pem', 'tls-ca-bundle.pem');
  fs.mkdirSync(trustDir, { recursive: true });
  await core.run('powershell.exe', [
    '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass',
    '-File', path.join(__dirname, 'windows-ca-bundle.ps1'),
    '-OutputPath', bundle,
    '-BaseBundle', baseBundle
  ], { timeout: 30000 });
  if (!fs.existsSync(bundle) || fs.statSync(bundle).size < 1024) throw new Error('Windows trusted-root export produced an empty CA bundle.');
  const posixBundle = await core.toPosix(bundle, perl);
  const env = core.caBundleEnvironment(posixBundle, core.cygwinEnvironment(perl));
  const curl = path.join(path.dirname(perl), 'curl.exe');
  try {
    await core.run(curl, ['-fsSIL', 'https://cpanmin.us'], { env, timeout: 30000 });
  } catch (error) {
    throw new Error(`Cygwin TLS verification failed after importing the Windows trusted roots. Ask IT to confirm the corporate TLS root is installed in Windows, then retry Quick Setup. ${error.message}`);
  }
  output.appendLine(`Cygwin TLS uses Windows and Cygwin trusted roots: ${bundle}`);
  return env;
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
  if(process.platform!=='win32'){setupStates.cygwin={status:'not needed',detail:'Cygwin is only used on Windows.'};setupStates.java={status:'pending',detail:'The platform installer checks Java.'};renderSetup();}
  await core.assertWritableProject(repo, undefined, { platform: 'native' });
  let perl = await findPerl();
  if (process.platform === 'win32' && !perl) {
    const choice = await vscode.window.showQuickPick(['Install Cygwin for me', 'Choose an existing Cygwin Perl'], { title: 'Windows requires Cygwin before MCP4SAS' });
    if (!choice) return;
    perl = choice.startsWith('Install') ? await bootstrapCygwin() : await choosePerl();
    if (!perl) return;
  }
  await core.assertWritableProject(repo, perl);
  const java = process.platform === 'win32' ? await setupStep('java','Find or install Windows Java',ensureWindowsJava) : undefined;
  if(process.platform === 'win32')await ensureCygwinPrerequisites(perl);
  const cygwinEnv = process.platform === 'win32' ? await prepareCygwinTrust(perl) : undefined;
  const install = core.platformInstaller(process.platform);
  fs.mkdirSync(context.globalStorageUri.fsPath, { recursive: true });
  if (fs.existsSync(path.join(repo, 'server.pl'))) {
    core.assertRepo(repo); // Never reset/pull an existing checkout silently.
    output.appendLine(`Using existing MCP4SAS source: ${repo}`);
    setupStates.source={status:'complete',detail:'Reusing the MCP4SAS source in this folder.'};renderSetup();
  } else {
    const git = process.platform === 'win32' ? path.join(path.dirname(perl), 'git.exe') : 'git';
    if (process.platform === 'linux') {
      try { await core.run(git, ['--version']); }
      catch { await task('/bin/bash', ['-c', 'sudo apt-get update\nsudo apt-get install -y git'], os.homedir()); }
    }
    const staging = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-source-'));
    try {
      const source = path.join(staging, 'source');
      await setupStep('source',`Download MCP4SAS scripts into ${repo}`,async()=>{
        await core.run(git, ['clone', '--depth', '1', 'https://github.com/chengzhongshan/MCP4SAS.git', source], { timeout: 300000, ...(process.platform === 'win32' ? { env: cygwinEnv } : {}) });
        core.installSourceFiles(source, repo);
      });
      output.appendLine(`MCP4SAS source copy completed: ${repo}`);
    } finally {
      await core.cleanupStaging(staging, message => output.appendLine(message));
    }
  }
  core.assertRepo(repo);
  output.appendLine(`MCP4SAS source and Perl runner available at: ${repo}`);
  const bash = process.platform === 'win32' ? path.join(path.dirname(perl), 'bash.exe') : '/bin/bash';
  const script = process.platform === 'win32' ? await core.toPosix(path.join(repo, 'install', install), perl) : path.join(repo, 'install', install);
  const logfile=path.join(repo,'local','install-logs','vscode-'+Date.now()+'.log');
  const wrapper=path.join(__dirname,'installer-task.sh');
  const [wrapperPath,logPath]=process.platform==='win32' ? await Promise.all([core.toPosix(wrapper,perl),core.toPosix(logfile,perl)]) : [wrapper,logfile];
  await setupStep('libraries','Install MCP4SAS libraries — keep the installer terminal open',()=>task(bash, ['--noprofile', '--norc', wrapperPath,logPath,script], repo, { ...(process.platform === 'win32' ? {...cygwinEnv,MCP4SAS_SKIP_CYGWIN_SETUP:'1'} : {}), ...(java ? { SASPY_JAVA_WIN: java } : {}) },{logFile:logfile}));
  if(process.platform!=='win32'){setupStates.java={status:'complete',detail:'Java checked by the platform installer.'};renderSetup();}
  // macOS installer may install Homebrew Perl for the first time.
  perl = core.installedPerl(await findPerl(), perl);
  return { repo, perl, java, cwd: repo };
}
async function saveRuntime(runtime) {
  if (!runtime?.perl) throw new Error('A Perl executable is required.');
  core.assertRepo(runtime.repo);
  const cwd = runtime.cwd || await folder('Choose your local SAS project folder (used for relative file and macro discovery)', vscode.workspace.workspaceFolders?.[0]?.uri.fsPath);
  if (!cwd) return false;
  await core.assertWritableProject(cwd, runtime.perl);
  fs.mkdirSync(context.globalStorageUri.fsPath, { recursive: true });
  // Stable copies survive extension versioned directory changes.
  refreshLauncher();
  const old = readConfig() || {};
  core.writePrivate(configFile(), JSON.stringify({ repo: runtime.repo, perl: runtime.perl, cwd, ...(runtime.java ? { java: runtime.java } : {}), ...Object.fromEntries(['saspyCfgname', 'saspyCfgfile', 'python', 'sessionPort', 'sasExecutable', 'targets'].filter(k => old[k]).map(k => [k, old[k]])) }, null, 2) + '\n');
  await configureCygwinTerminal(runtime.perl);
  await configureProjectTerminal(cwd);
  output.appendLine(`MCP4SAS source/runtime folder: ${runtime.repo}`);
  output.appendLine(`SAS project folder (data and macros): ${cwd}`);
  output.appendLine('For manual SAS submissions, run MCP4SAS: Open MCP4SAS Runtime Terminal.');
  // Detect first so the new terminal inherits the chosen ODA/local environment.
  if (!await detectSetup(true)) return false;
  const message = `MCP4SAS scripts are installed in ${runtime.repo}. Your SAS project is ${cwd}.`;
  if (process.platform === 'win32') {
    await openRuntimeTerminal();
    vscode.window.showInformationMessage(message);
  } else if (await vscode.window.showInformationMessage(message, 'Open Runtime Terminal') === 'Open Runtime Terminal') await openRuntimeTerminal();
  emitter.fire(); return true;
}
async function openRuntimeTerminal() {
  trusted(); const config = readConfig(); if (!config) return setup();
  core.assertRepo(config.repo);
  const folders = vscode.workspace.workspaceFolders || [];
  const active = vscode.window.activeTextEditor && vscode.workspace.getWorkspaceFolder?.(vscode.window.activeTextEditor.document.uri);
  const selected = active || (folders.length === 1 ? folders[0] : folders.length > 1 ? await vscode.window.showWorkspaceFolderPick({ placeHolder: 'Choose the open folder for your Cygwin terminal' }) : undefined);
  if (folders.length && !selected) return;
  const cwd = selected?.uri.fsPath || config.cwd;
  await core.assertWritableProject(cwd, config.perl);
  await configureProjectTerminal(cwd);
  const env = await core.runtimeEnvironment(config);
  if (process.platform === 'win32') env.CHERE_INVOKING = '1';
  if (process.platform !== 'win32') env.PATH = path.dirname(config.perl) + path.delimiter + (env.PATH || '');
  const terminal = vscode.window.createTerminal({
    name: 'MCP4SAS Runtime', cwd, env,
    shellPath: process.platform === 'win32' ? path.join(path.dirname(config.perl), 'bash.exe') : '/bin/bash',
    shellArgs: ['--login', '-i']
  });
  terminal.show();
  const runner = cwd === config.repo ? 'run_sas_codes_or_files_in_ODA.pl' : core.shellQuote(await core.toPosix(path.join(config.repo, 'run_sas_codes_or_files_in_ODA.pl'), config.perl));
  output.appendLine(`Terminal folder (VS Code and Cygwin write check passed): ${cwd}`);
  output.appendLine(`Manual command from this terminal: perl ${runner} --code 'proc print data=sashelp.class; run;'`);
  return terminal;
}
async function configureProjectTerminal(cwd) {
  if (process.platform !== 'win32' || vscode.env.remoteName) return;
  const workspace = (vscode.workspace.workspaceFolders || []).find(f => f.uri.fsPath.toLowerCase() === cwd.toLowerCase());
  if (!workspace) return;
  // Override a stale terminal cwd only in this folder, never for other projects.
  await vscode.workspace.getConfiguration('terminal.integrated', workspace.uri).update('cwd', '${workspaceFolder}', vscode.ConfigurationTarget.WorkspaceFolder);
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
  for (const name of ['relay.js', 'core.js', 'routing.js']) core.writePrivate(path.join(context.globalStorageUri.fsPath, name), fs.readFileSync(path.join(context.extensionPath, 'src', name)));
}
async function setup() {
  if(setupPromise){showSetupGuide();return setupPromise;}
  setupPromise=runSetup();
  try{return await setupPromise;}finally{setupPromise=undefined;}
}
async function runSetup() {
  showSetupGuide();
  if(!await ensureSetupWorkspace())return;
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
  const connected=await connect();
  setupStates.assistant=connected?{status:'complete',detail:'Connection choices saved. Refresh the selected assistant to use its tools.'}:{status:'action needed',detail:'Run Connect Copilot and/or Codex to choose your assistant.'};
  renderSetup('Runtime setup finished. Use the SAS access steps below for any missing JARs or credentials, then Test selected SAS.');
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
  return true;
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
    const target = config.saspyCfgname || process.env.SASPY_CFGNAME || 'oda';
    const prompt = 'Use saspy_cfgname=' + target + '. Use MCP4SAS to run proc means data=sashelp.class n nmiss min max; var Age; run; on my configured SASPy target in a fresh session. Wait for the final result and inspect the actual SAS log. Check known ages=19, missing=0, minimum=11, maximum=16. Show the tool call and observed values; do not infer successful execution from code alone.';
      const message = target === 'oda'
        ? 'Tools discovered; SAS login and encryption JARs still need verification. Configure missing prerequisites before running the SAS test.'
        : `Tools discovered for SASPy profile ${target}; local/remote SAS execution still needs verification. Confirm that SAS is installed and licensed and that this profile is configured.`;
      const actions = target === 'oda'
        ? ['Copy SAS test prompt', 'Configure ODA login', 'Configure SAS JARs', 'Open setup guide']
        : ['Copy SAS test prompt', 'Open setup guide'];
      const action = await vscode.window.showInformationMessage(message, ...actions);
    if (action === 'Copy SAS test prompt') await vscode.env.clipboard.writeText(prompt);
    if (action === 'Configure ODA login') await configureLogin();
    if (action === 'Configure SAS JARs') await configureJars();
    if (action === 'Open setup guide') await help();
  } finally { clearTimeout(timer); rl.close(); p.stdin.end(); }
}
async function help() { if(!showSetupGuide())await vscode.commands.executeCommand('markdown.showPreview', vscode.Uri.file(path.join(context.extensionPath, 'README.md'))); }
async function installLocalSupport(config, found) {
  return nativePython.ensure({storage:context.globalStorageUri.fsPath,config,found,
    platform:process.platform,run:core.run,task,detect:discovery.detect,log:line=>output.appendLine(line)});
}
async function detectSetup(choose=false,forceChoice=false) {
  trusted();const saved=readConfig();if(!saved)return setup();const config={...saved,saspyCfgname:saved.saspyCfgname||process.env.SASPY_CFGNAME};
  core.assertRepo(config.repo);
  if(!config.saspyCfgfile&&process.env.SASPY_CFGFILE&&process.env.SASPY_CFGNAME===config.saspyCfgname)config.saspyCfgfile=process.env.SASPY_CFGFILE;
  output.appendLine('Detecting Python, SASPy, local SAS and SAS encryption files. No SAS code or login is submitted.');
  let found=await vscode.window.withProgress({location:vscode.ProgressLocation.Notification,title:'Finding your SAS software'},()=>discovery.detect(config));
  const localName=/^(winlocal|winlocal_com|linuxlocal|local|stdio)$/;
  const custom=config.saspyCfgname&&config.saspyCfgname!=='oda'&&!localName.test(config.saspyCfgname);
  let kind=custom?'custom':localName.test(config.saspyCfgname||'')?'local':'oda';
  if(choose && (found.sas||custom||forceChoice)) {
    const options=[{label:'SAS OnDemand for Academics',kind:'oda',description:kind==='oda'?'Currently selected':'Use your online SAS account'}];
    if(found.sas)options.push({label:'SAS installed on this computer',kind:'local',description:kind==='local'?'Currently selected':found.platform==='linux'?'Use detected Linux SAS (STDIO)':found.local?'Use detected Windows SAS':'Set up Python support automatically'});
    if(custom)options.unshift({label:'Keep my configured SAS connection',kind:'custom'});
    const selected=await vscode.window.showQuickPick(options,{title:'Where would you like to run SAS?'});if(!selected)return false;kind=selected.kind;
  }
  const managedPython=path.join(context.globalStorageUri.fsPath,'native-saspy',process.platform==='win32'?'Scripts/python.exe':'bin/python');
  const savedLocalPython=config.targets?.local?.python||(kind==='local'?config.python:undefined);
  const brokenManaged=savedLocalPython&&path.resolve(savedLocalPython)===path.resolve(managedPython)&&!found.python.some(p=>p.candidate===savedLocalPython&&p.saspy&&p.native_compatible!==false);
  if(kind==='local'&&(!found.local||brokenManaged))found=await installLocalSupport(config,found);
  let updated=kind==='custom'?{...config}:discovery.configuredTarget(config,found,kind);
  if(kind==='custom'&&config.python&&!found.python.some(x=>x.saspy&&(x.candidate===config.python||x.python===config.python)))throw new Error('The Python saved for your custom SAS connection is unavailable or cannot import SASPy. Restore that environment or rerun Quick Setup. Your custom connection was preserved.');
  const generatedLocalFile=path.join(context.globalStorageUri.fsPath,'detected-local-sas.py');
  if(kind==='local'&&(!updated.saspyCfgfile||updated.saspyCfgfile===generatedLocalFile)) {
    const file=path.join(context.globalStorageUri.fsPath,'detected-local-sas.py');
    const text=localProfile.source(updated,process.platform);
    core.writePrivate(file,text);updated.saspyCfgfile=file;
  }
  if(kind==='oda'&&!updated.saspyCfgfile&&fs.existsSync(path.join(config.repo,'sascfg_personal.py')))updated.saspyCfgfile=path.join(config.repo,'sascfg_personal.py');
  const remembered=updated.targets?.[kind]||config;
  const before=JSON.stringify([remembered.python,remembered.saspyCfgname,remembered.saspyCfgfile,remembered.sasExecutable]),after=JSON.stringify([updated.python,updated.saspyCfgname,updated.saspyCfgfile,updated.sasExecutable]);
  if(before!==after||discovery.needsSessionPort(updated)) {
    const previousPort=updated.sessionPort;
    updated.sessionPort=await core.allocateSessionPort();
    if(previousPort)output.appendLine('Using a fresh helper port for '+updated.saspyCfgname+'. Existing SAS sessions on the previous port are preserved; they have not been stopped.');
  }
  updated.sessionBinding=discovery.sessionBinding(updated);
  updated.targets=discovery.rememberTargets(updated);
  core.writePrivate(configFile(),JSON.stringify(updated,null,2)+'\n');emitter.fire();
  updateTargetStatus();
  output.appendLine('Detected Python: '+(updated.python||'installer environment')+'; SASPy target: '+(updated.saspyCfgname||'oda'));
  if(kind==='oda'&&found.oda?.missing_jars?.length&&found.jarDirectory)await configureJars(found.jarDirectory);
  else if(kind==='oda'&&found.oda?.missing_jars?.length) {
    output.appendLine('SAS encryption files are missing. The setup guide has the official SAS download and a ZIP/folder selector.');
    showSetupGuide();setupStates.sas={status:'action needed',detail:'Get the three SAS encryption JARs using the download instructions below, then configure your private ODA login.'};renderSetup('ODA is selected; SAS execution is not verified yet.');
  } else {setupStates.sas={status:'ready to test',detail:'SAS environment detected. Test selected SAS to verify actual execution.'};renderSetup();}
  if(choose) {
    const needsJars=kind==='oda'&&found.oda?.missing_jars?.length&&!found.jarDirectory;
    const action=needsJars
      ? await vscode.window.showInformationMessage('SAS OnDemand is selected, but its encryption files are missing. Complete the SAS download and private login steps in the setup guide before testing.','Open Setup Guide','Configure SAS JARs')
      : await vscode.window.showInformationMessage('SAS target saved: '+(updated.saspyCfgname==='oda'?'SAS ODA':kind==='local'?'Local SAS':'Configured SAS')+'. New assistant submissions and new project terminals use this selection. Existing terminals keep their old environment; open a new terminal before running manual commands.','Test SAS Now','Open Runtime Terminal');
    if(action==='Open Setup Guide')showSetupGuide();
    if(action==='Configure SAS JARs')await configureJars();
    if(action==='Test SAS Now')await testSelectedSas();
    if(action==='Open Runtime Terminal')await openRuntimeTerminal();
  }
  return true;
}
function updateTargetStatus() {
  const config=readConfig();
  if(!config){terminalTarget.apply(context,vscode,null);if(targetStatus){targetStatus.text='$(database) Set Up SAS';targetStatus.tooltip='Configure MCP4SAS for this computer';targetStatus.command='mcp4sas.setup';targetStatus.show();}return;}
  const profile=config.saspyCfgname||'oda';
  try {core.assertRepo(config.repo);if(!fs.statSync(config.cwd).isDirectory())throw Error('Saved project folder is unavailable.');}
  catch(error){terminalTarget.apply(context,vscode,null);if(targetStatus){targetStatus.text='$(warning) Repair SAS Setup';targetStatus.tooltip=error.message;targetStatus.command='mcp4sas.setup';targetStatus.show();}return;}
  terminalTarget.apply(context,vscode,config);
  if(!targetStatus)return;
  const label=profile==='oda'?'SAS ODA':profile.startsWith('win')?'Windows SAS':/^(linuxlocal|local|stdio)$/.test(profile)?'Linux SAS':profile;
  targetStatus.text='$(database) '+label;
  targetStatus.tooltip='MCP4SAS selected target: '+profile+'. Click to switch. Software detection does not verify SAS execution.';
  targetStatus.command='mcp4sas.switchSas';targetStatus.show();
}
async function testSelectedSas() {
  trusted();const config=readConfig();if(!config)return setup();
  const directory=path.join(context.globalStorageUri.fsPath,'connection-checks',String(Date.now()));
  const env=await core.runtimeEnvironment(config);
  const runner=await core.toPosix(path.join(config.repo,'run_sas_codes_or_files_in_ODA.pl'),config.perl);
  const destination=await core.toPosix(directory,config.perl);
  output.show(true);output.appendLine('Testing selected SAS target '+(config.saspyCfgname||'oda')+'; actual submission of SASHELP.CLASS.');
  await vscode.window.withProgress({location:vscode.ProgressLocation.Notification,title:'Testing '+(config.saspyCfgname||'oda')},async()=>{
    const result=await core.run(config.perl,[runner,'--code',targetCheck.CODE,'--output-prefix',destination,'--run-timeout-seconds','120'],{cwd:config.cwd,env,timeout:180000});
    output.appendLine(result);
    // The CLI may return a compact path-only summary. Check the saved SAS log,
    // not stdout or the submitted program's echoed source.
    const log=fs.readFileSync(path.join(directory,'output.html.info.txt'),'utf8');
    output.appendLine(log);
    try {targetCheck.verify(log,config.saspyCfgname||'oda');}
    catch(error){throw new Error(error.message+' Inspect Output > MCP4SAS and '+directory);}
  });
  output.appendLine('Verified SAS target '+(config.saspyCfgname||'oda')+'. Log and output: '+directory);
  setupStates.sas={status:'complete',detail:'Actual SAS execution verified: 19 ages, 0 missing, minimum 11, maximum 16.'};renderSetup('SAS test passed. You can now use your selected assistant or the project runners.');
  await vscode.window.showInformationMessage('SAS execution verified: 19 ages, 0 missing, minimum 11, maximum 16. Target: '+(config.saspyCfgname||'oda'));
  return directory;
}
async function configureLogin() {
  trusted(); const config = readConfig(); if (!config) return setup();
  if (config.saspyCfgname && config.saspyCfgname !== 'oda') throw new Error('ODA login applies only to SAS OnDemand. Use MCP4SAS: Detect SAS Setup to choose SAS OnDemand, or use local SAS without ODA credentials.');
  core.assertRepo(config.repo);
  const env = await core.runtimeEnvironment(config);
  const runner = await core.toPosix(path.join(config.repo, 'run_sas_codes_or_files_in_ODA.pl'), config.perl);
  output.appendLine('Opening private terminal login using the selected runtime and HOME. Do not enter passwords in AI chat.');
  await task(config.perl, [runner, '--prompt-sas-oda-auth', '--check-sas-oda-login-only'], config.repo, { ...env, SASPY_CFGNAME: 'oda', SAS_ODA_AUTOLOAD_MACROS: '0' });
  vscode.window.showInformationMessage('ODA login validation completed. Retry your SAS request from the assistant.');
}
async function configureJars(detectedDirectory) {
  trusted(); const config = readConfig(); if (!config) return setup();
  if(/^(winlocal_com|linuxlocal|local|stdio)$/.test(config.saspyCfgname||''))throw new Error('SAS encryption JARs are for an ODA/IOM connection. Local SAS COM/STDIO does not require them. Switch to your ODA/IOM target before configuring its JARs.');
  showSetupGuide();
  let source=typeof detectedDirectory==='string'?detectedDirectory:undefined;
  if(!source) {
    const choice=await vscode.window.showQuickPick(['Select downloaded SAS ZIP','Select extracted SAS folder','Open official SAS download page'],{title:'SAS encryption files — from SAS, not a third-party download'});
    if(!choice)return;
    if(choice.startsWith('Open')){await vscode.env.openExternal(vscode.Uri.parse(guide.SAS_DOWNLOAD));renderSetup('Sign in on the SAS website, download the archive, then Select downloaded ZIP or folder here.');return;}
    if(choice.includes('ZIP'))source=(await vscode.window.showOpenDialog({title:'Select the SAS-provided ZIP archive in Downloads',canSelectFiles:true,canSelectFolders:false,canSelectMany:false,filters:{'ZIP archives':['zip']},defaultUri:vscode.Uri.file(path.join(os.homedir(),'Downloads'))}))?.[0].fsPath;
    else source=await folder('Select the extracted SAS download folder (inner subfolders are searched)',path.join(os.homedir(),'Downloads'));
  }
  if(!source)return;
  if(!config.python)throw new Error('Finish Quick Setup so MCP4SAS can find your SASPy Python, then select the SAS download.');
  const env = await core.runtimeEnvironment(config);
  let command=config.python,args=[path.join(__dirname,'sas_jars.py'),'--source',source];
  if(process.platform==='win32'&&!/^[A-Za-z]:[\\/].*\.exe$/i.test(config.python)) {
    command=path.join(path.dirname(config.perl),'bash.exe');
    args=['--noprofile','--norc','-c','exec "$@"','mcp4sas-jars',config.python,await core.toPosix(path.join(__dirname,'sas_jars.py'),config.perl),'--source',await core.toPosix(source,config.perl)];
  }
  let result;
  try {result=await setupStep('sas','Install the SAS encryption files into the selected SASPy environment',()=>core.run(command,args,{cwd:config.repo,env,timeout:120000}));}
  catch(error){throw new Error(`${error.message}\nDownload all three files (sas.rutil.jar, sas.rutil.nls.jar, sastpj.rutil.jar) from ${guide.SAS_DOWNLOAD} using your SAS Profile. Select the SAS ZIP or extracted folder in the setup guide.`);}
  if(!result.includes('MCP4SAS_JARS_JSON='))throw new Error('SAS JAR installation did not return its verification record. Inspect the MCP4SAS output.');
  output.appendLine(result);
  setupStates.sas={status:'ready to test',detail:'Three SAS encryption files installed in the selected SASPy. Configure ODA login and test a fresh SAS session; custom explicit classpaths must include these files.'};renderSetup();
  vscode.window.showInformationMessage('SAS encryption files installed. Configure ODA login, then Test Selected SAS. If your custom SASPy configuration explicitly sets a classpath, ensure it includes these three files; existing SAS sessions need restarting.','OK');
}
async function activate(ctx) {
  context = ctx; output = vscode.window.createOutputChannel('MCP4SAS'); emitter = new vscode.EventEmitter();
  if (vscode.workspace.isTrusted && !vscode.env.remoteName && fs.existsSync(configFile())) refreshLauncher();
  context.subscriptions.push(output, emitter);
  if(vscode.window.createStatusBarItem) { targetStatus=vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right,95);context.subscriptions.push(targetStatus);updateTargetStatus(); }
  for (const [id, fn] of Object.entries({ setup, connect, check, help, detectSetup: () => detectSetup(true), switchSas: () => detectSetup(true,true), testSas: testSelectedSas, configureLogin, configureJars, openRuntimeTerminal, cygwinTerminal: useCygwinTerminal })) context.subscriptions.push(vscode.commands.registerCommand(`mcp4sas.${id}`, async () => { try { return await fn(); } catch (e) { output.appendLine(e.message); output.show(true); vscode.window.showErrorMessage(`MCP4SAS: ${e.message}`); } }));
  const provider = {
    onDidChangeMcpServerDefinitions: emitter.event,
    provideMcpServerDefinitions() {
      if (!vscode.workspace.isTrusted || vscode.env.remoteName || !context.globalState.get('copilotEnabled') || !readConfig()) return [];
      try {const config=readConfig();core.assertRepo(config.repo);if(!fs.statSync(config.cwd).isDirectory())throw Error('Saved project folder is unavailable. Run MCP4SAS: Quick Setup.');}
      catch(error){output.appendLine(error.message);return [];}
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
  const pending=context.globalState.get('pendingSetup');
  if(vscode.workspace.isTrusted&&!vscode.env.remoteName&&guide.pendingMatches(pending,vscode.workspace.workspaceFolders||[])) {
    await context.globalState.update('pendingSetup',undefined);
    Promise.resolve().then(()=>setup()).catch(error=>{output.appendLine(error.message);showSetupGuide();renderSetup(error.message);vscode.window.showErrorMessage('MCP4SAS: '+error.message);});
  }
  return { provider, configFile, launchSettings, configureCygwinTerminal, openRuntimeTerminal, detectSetup, testSelectedSas, updateTargetStatus, task, ensureSetupWorkspace, setupStep, bootstrapCygwin, showSetupGuide }; // Also exercised by extension-host tests.
}
module.exports = { activate };
