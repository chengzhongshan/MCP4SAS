'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const vm = require('node:vm');
const { createRequire } = require('node:module');
const core = require('../src/core');

test('Quick Setup saves a portable Cygwin runtime and connects Copilot after installation', async () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-portable-'));
  const extensionPath = path.resolve(__dirname, '..');
  const portable = path.join(root, 'portable Cygwin', 'bin', 'perl.exe');
  const java = path.join(root, 'Java', 'bin', 'java.exe');
  const project = path.join(root, 'SAS project');
  const storage = path.join(root, 'storage');
  for (const file of [portable, java, path.join(path.dirname(portable), 'cygpath.exe'), path.join(path.dirname(portable), 'bash.exe')]) {
    fs.mkdirSync(path.dirname(file), { recursive: true }); fs.writeFileSync(file, 'fixture');
  }
  fs.mkdirSync(project);
  const commands = new Map(), states = new Map(), errors = [], tasks = [], terminals = [], jarsCalls=[];
  const settings = new Map([['profiles.windows', { 'My existing shell': { path: 'original.exe' } }]]);
  let configureTerminal = true, sasCheckFailure = false;
  const statusBar={show(){},dispose(){}};
  const choices = ['Install MCP4SAS for this computer', 'Choose an existing Cygwin Perl', [{ label: 'GitHub Copilot' }]];
  const dialogs = [portable];
  let onTaskEnd,taskExitCode=0,missingPrerequisites='',busyPrerequisites=false;
  const disposable = () => ({ dispose() {} });
  const vscode = {
    workspace: { isTrusted: true, workspaceFolders: [{ uri: { fsPath: project } }], getConfiguration(section) {
      if (section === 'mcp4sas') return { get: () => configureTerminal };
      return { inspect: key => ({ globalValue: settings.get(key) }), async update(key, value) { settings.set(key, value); } };
    } }, env: {}, ConfigurationTarget: { Global: 1, WorkspaceFolder: 3 },
    Uri: { file: fsPath => ({ fsPath }) },
    ProgressLocation: { Notification: 1 }, StatusBarAlignment: {Right:2}, TaskScope: { Global: 1 }, TaskRevealKind: {}, TaskPanelKind: {},
    EventEmitter: class { event() {} fire() {} dispose() {} },
    ShellExecution: class { constructor() { throw new Error('Installer must not use the default terminal shell'); } },
    ProcessExecution: class { constructor(command, args, options) { Object.assign(this, { command, args, options }); } },
    Task: class { constructor(definition, scope, name, source, execution) { Object.assign(this, { definition, execution }); } },
    commands: { registerCommand(id, fn) { commands.set(id, fn); return disposable(); } },
    lm: { registerMcpServerDefinitionProvider: disposable },
    window: {
      createStatusBarItem() { return statusBar; },
      createTerminal(options) { terminals.push(options); return { show() {} }; },
      createOutputChannel: () => ({ appendLine() {}, show() {}, dispose() {} }),
      showQuickPick: async () => choices.shift(),
      showOpenDialog: async () => [{ fsPath: dialogs.shift() }],
      withProgress: async (options, fn) => fn(),
      showInformationMessage(message) { return message.startsWith('MCP4SAS scripts are installed') ? new Promise(() => {}) : undefined; }, showErrorMessage: message => errors.push(message)
    },
    tasks: {
      onDidEndTaskProcess(fn) { onTaskEnd = fn; return disposable(); },
      async executeTask(task) { tasks.push(task); if(task.execution.args[1]==='venv'){const exe=path.join(task.execution.args[2],'Scripts','python.exe');fs.mkdirSync(path.dirname(exe),{recursive:true});fs.writeFileSync(exe,'fixture');} const execution={task:{...task,definition:{type:'process'}}};queueMicrotask(() => onTaskEnd({ execution, exitCode: taskExitCode }));return execution; }
    }
  };
  const mockedCore = {
    ...core,
    async assertWritableProject(directory) { return core.assertWritableProject(directory, undefined, { platform: 'native' }); },
    async runtimeEnvironment(config) { return { HOME: '/selected/private-home', PIPELINE_PYTHON_BIN: 'selected-python', SASPY_CFGNAME: config.saspyCfgname }; },
    async run(command, args, options = {}) {
      if(args.includes(require('../src/native-python').PROBE)) {
        if(!fs.existsSync(command))throw Error('Python not installed');
        return JSON.stringify({platform:'win32',version:[3,13],bits:64});
      }
      if(args.includes('import saspy, win32com.client'))return '';
      if(args.some(value=>String(value).endsWith('sas_jars.py'))) {
        jarsCalls.push({command,args,options});
        const source=args[args.indexOf('--source')+1];
        if(['sas.rutil.jar','sas.rutil.nls.jar','sastpj.rutil.jar'].some(name=>!fs.existsSync(path.join(source,name))))throw Error('SAS JAR setup: Missing sas.rutil.jar');
        return 'MCP4SAS_JARS_JSON={"verified":true}';
      }
      if(command===path.join(path.dirname(portable),'bash.exe')&&args.includes('-c')) {
        if(args.at(-1).includes('MCP4SAS_PROBE_PID='))return 'MCP4SAS_PROBE_PID=100\n 100 1 100 1000 ?\n'+(busyPrerequisites?' 200 1 200 2000 ?\n':'');
        return missingPrerequisites;
      }
      if(command==='powershell.exe') {
        const bundle=args[args.indexOf('-OutputPath')+1];
        fs.mkdirSync(path.dirname(bundle),{recursive:true});fs.writeFileSync(bundle,'certificate fixture\n'.repeat(100));
        return '';
      }
      if(command===path.join(path.dirname(portable),'curl.exe')) {
        assert.equal(options.env.CURL_CA_BUNDLE,path.join(storage,'trust','windows-cygwin-ca-bundle.pem'));
        return 'HTTP/2 200';
      }
      if(args.includes('--code')) {
        const directory=args[args.indexOf('--output-prefix')+1];fs.mkdirSync(directory,{recursive:true});
        fs.writeFileSync(path.join(directory,'output.html.info.txt'),(sasCheckFailure?'ERROR: test failure\n':'')+'MCP4SAS_TARGET_CHECK n=19 missing=0 minimum=11 maximum=16\n');
        return 'SAS log saved to: '+directory;
      }
      assert.equal(command, path.join(path.dirname(portable), 'git.exe'));
      assert.equal(args[0], 'clone');
      assert.equal(options.env.GIT_SSL_CAINFO,path.join(storage,'trust','windows-cygwin-ca-bundle.pem'));
      const repo = args.at(-1);
      for (const file of ['server.pl', 'run_sas_codes_or_files_in_ODA.pl', 'MCPDeps/SAS_ODA_Runner.pm', 'install/common.sh']) {
        const target = path.join(repo, file); fs.mkdirSync(path.dirname(target), { recursive: true }); fs.writeFileSync(target, 'fixture');
      }
      return '';
    },
    async toPosix(value, perl) { assert.equal(perl, portable); return value; }
  };
  let detected = {platform:'win32',python:[],oda:{candidate:'selected-python',platform:'cygwin',python:'/selected/python',saspy:true,missing_jars:[]}};
  const mockDiscovery = {...require('../src/detect'), async detect(config) { if(config.python?.includes('native-saspy'))return {...detected,local:{candidate:config.python,platform:'win32',saspy:true,com:true}};return detected; }};
  const realRequire = createRequire(path.join(extensionPath, 'src', 'extension.js'));
  const module = { exports: {} };
  try {
    vm.runInNewContext(fs.readFileSync(path.join(extensionPath, 'src', 'extension.js'), 'utf8'), {
      module, __dirname:path.join(extensionPath,'src'), process: { platform: 'win32', execPath: process.execPath, env: { LOCALAPPDATA: root, ProgramFiles: root, SASPY_JAVA_WIN: java } },
      require(name) {
        if (name === 'vscode') return vscode;
        if (name === './core') return mockedCore;
        if (name === './detect') return mockDiscovery;
        if (name === 'node:fs') return { ...fs, existsSync(file) { return String(file).startsWith(root) && fs.existsSync(file); } };
        return realRequire(name);
      }
    });
    const api = await module.exports.activate({ extensionPath, globalStorageUri: { fsPath: storage }, subscriptions: [], globalState: { get: key => states.get(key), async update(key, value) { states.set(key, value); } } });
    assert.match(statusBar.text,/Set Up SAS/);
    await commands.get('mcp4sas.setup')();
    assert.deepEqual(errors, []);
    const saved = JSON.parse(fs.readFileSync(path.join(storage, 'runtime.json'), 'utf8'));
    assert.equal(saved.perl, portable);
    assert.equal(saved.cwd, project);
    assert.equal(saved.repo, project, 'scripts are installed directly in the open workspace');
    assert.equal(saved.java, java);
    assert.match(statusBar.text,/SAS ODA/);assert.equal(statusBar.command,'mcp4sas.switchSas');
    assert.ok(fs.existsSync(path.join(saved.repo, 'run_sas_codes_or_files_in_ODA.pl')));
    assert.equal(terminals.length, 1, 'Windows setup automatically opens the project terminal');
    assert.equal(terminals[0].env.SASPY_CFGNAME, 'oda', 'automatic terminal uses the newly detected SAS target');
    assert.equal(settings.get('cwd'), '${workspaceFolder}', 'workspace terminal cwd follows the open folder');
    await commands.get('mcp4sas.openRuntimeTerminal')();
    assert.equal(terminals.at(-1).cwd, project, 'manual terminal opens in the current VS Code project');
    assert.equal(terminals.at(-1).shellPath, path.join(path.dirname(portable), 'bash.exe'));
    assert.equal(terminals.at(-1).env.HOME, '/selected/private-home');
    assert.equal(terminals.at(-1).env.CHERE_INVOKING, '1');
    const otherProject = path.join(root, "Another reader's project"); fs.mkdirSync(otherProject);
    vscode.workspace.workspaceFolders = [{ uri: { fsPath: otherProject } }];
    await commands.get('mcp4sas.openRuntimeTerminal')();
    assert.equal(terminals.at(-1).cwd, otherProject, 'changing the open folder does not reopen the old runtime directory');
    vscode.workspace.workspaceFolders = [{ uri: { fsPath: project } }];
    assert.equal(tasks[0].execution.command, path.join(path.dirname(portable), 'bash.exe'));
    assert.ok(tasks[0].execution instanceof vscode.ProcessExecution);
    assert.equal(tasks[0].definition.type,'process','uses the built-in task type, not an unregistered custom provider');
    assert.equal(tasks[0].execution.options.env.MCP4SAS_SKIP_CYGWIN_SETUP,'1','verified existing Cygwin is never upgraded from its own Bash');
    assert.equal(tasks[0].execution.options.env.CURL_CA_BUNDLE,path.join(storage,'trust','windows-cygwin-ca-bundle.pem'),'installer receives the verified Windows/Cygwin CA bundle');
    assert.deepEqual(Array.from(tasks[0].execution.args).slice(0, 2), ['--noprofile', '--norc']);
    assert.equal(states.get('copilotEnabled'), true);
    assert.ok(fs.existsSync(path.join(storage, 'relay.js')));
    assert.equal(settings.get('defaultProfile.windows'), 'MCP4SAS Cygwin');
    const profile = settings.get('profiles.windows')['MCP4SAS Cygwin'];
    assert.equal(profile.path, path.join(path.dirname(portable), 'bash.exe'));
    assert.equal(Array.from(profile.args).join(' '), '--login -i');
    assert.equal(profile.env.CHERE_INVOKING, '1');
    assert.equal(settings.get('profiles.windows')['My existing shell'].path, 'original.exe');
    settings.set('defaultProfile.windows', 'My existing shell');
    await api.configureCygwinTerminal(portable);
    assert.equal(settings.get('defaultProfile.windows'), 'My existing shell', 'later user preference is retained');
    await commands.get('mcp4sas.cygwinTerminal')();
    assert.equal(settings.get('defaultProfile.windows'), 'MCP4SAS Cygwin');
    configureTerminal = false;
    settings.set('defaultProfile.windows', 'My existing shell');
    states.delete('cygwinTerminalConfigured');
    await api.configureCygwinTerminal(portable);
    assert.equal(settings.get('defaultProfile.windows'), 'My existing shell', 'opt out is respected');
    await commands.get('mcp4sas.configureLogin')();
    assert.equal(tasks.at(-1).execution.command, portable);
    assert.equal(tasks.at(-1).execution.options.env.HOME, '/selected/private-home');
    assert.equal(tasks.at(-1).execution.options.env.SASPY_CFGNAME, 'oda');
    assert.ok(tasks.at(-1).execution.args.includes('--prompt-sas-oda-auth'));
    assert.ok(!tasks.at(-1).execution.args.includes('--sas-oda-password'));
    const jars = path.join(root, 'SAS JAR files'); fs.mkdirSync(jars);
    choices.push('Select extracted SAS folder');
    dialogs.push(jars);
    const beforeTasks = tasks.length;
    await commands.get('mcp4sas.configureJars')();
    assert.equal(tasks.length, beforeTasks, 'missing JARs do not run the installer');
    assert.match(errors.at(-1), /sas\.rutil\.jar/);
    assert.match(errors.at(-1), /pid=2494/);
    for (const name of ['sas.rutil.jar', 'sas.rutil.nls.jar', 'sastpj.rutil.jar']) fs.writeFileSync(path.join(jars, name), 'fixture');
    choices.push('Select extracted SAS folder');
    dialogs.push(jars);
    await commands.get('mcp4sas.configureJars')();
    assert.equal(tasks.length, beforeTasks, 'JAR helper uses the selected Python directly');
    assert.equal(jarsCalls.length,2);
    assert.equal(jarsCalls.at(-1).args.at(-1),jars);
    assert.ok(jarsCalls.at(-1).args.includes('/selected/python'),'selected SASPy environment receives the JARs');
    assert.equal(commands.has('mcp4sas.selectConnection'), false, 'complex manual selector is removed');
    const python = path.join(root,'native-python.exe'); fs.writeFileSync(python,'fixture');
    detected={...detected,sas:path.join(root,'sas.exe'),local:{candidate:python,saspy:true,com:true,platform:'win32'}};
    choices.push({label:'SAS installed on this computer',kind:'local'});
    const dialogsBefore=dialogs.length;
    await commands.get('mcp4sas.detectSetup')();
    const local=JSON.parse(fs.readFileSync(path.join(storage,'runtime.json'),'utf8'));
    assert.equal(local.saspyCfgname,'winlocal');assert.equal(local.python,python);
    assert.match(statusBar.text,/Windows SAS/);
    assert.equal(dialogs.length,dialogsBefore,'no Python or config file picker is needed');
    assert.match(fs.readFileSync(local.saspyCfgfile,'utf8'),/java.library.path/);
    assert.ok(!fs.readFileSync(local.saspyCfgfile,'utf8').includes('sas.iomprovider'));
    assert.ok(Number(local.sessionPort)>0);
    await commands.get('mcp4sas.configureLogin')();assert.match(errors.at(-1),/ODA login applies only/);
    choices.push({label:'SAS installed on this computer',kind:'local'});
    await commands.get('mcp4sas.detectSetup')();
    assert.equal(JSON.parse(fs.readFileSync(path.join(storage,'runtime.json'),'utf8')).sessionPort,local.sessionPort,'unchanged detection keeps the session port');
    choices.push({label:'SAS OnDemand for Academics',kind:'oda'});
    await commands.get('mcp4sas.detectSetup')();
    const oda=JSON.parse(fs.readFileSync(path.join(storage,'runtime.json'),'utf8'));
    assert.equal(oda.saspyCfgname,'oda');assert.equal(oda.python,'/selected/python','ODA returns to detected Cygwin Python');
    assert.match(statusBar.text,/SAS ODA/);
    const checkedDirectory=await api.testSelectedSas();assert.ok(fs.existsSync(path.join(checkedDirectory,'output.html.info.txt')),'compact CLI stdout is checked through the real log file');
    sasCheckFailure=true;await assert.rejects(api.testSelectedSas(),/did not return the expected observed values/);sasCheckFailure=false;
    detected={...detected,local:undefined,native:{candidate:python,saspy:false}};
    choices.push({label:'SAS installed on this computer',kind:'local'});
    const beforeInstall=tasks.length;
    await commands.get('mcp4sas.detectSetup')();
    assert.equal(tasks.length,beforeInstall+2,'missing support creates a private venv and installs its dependencies');
    assert.equal(tasks.at(-2).execution.command,python);
    assert.deepEqual(Array.from(tasks.at(-2).execution.args).slice(0,2),['-m','venv']);
    assert.match(tasks.at(-1).execution.command,/native-saspy/);
    assert.ok(tasks.at(-1).execution.args.includes('saspy'));assert.ok(tasks.at(-1).execution.args.includes('pywin32'));
    assert.notEqual(tasks.at(-1).execution.command,python,'base Python packages are not modified');
    const failedLog=path.join(project,'failed-install.log');fs.writeFileSync(failedLog,'ERROR: fixture prerequisite failed\n');
    taskExitCode=17;
    await assert.rejects(api.task('fixture',['install'],project,{}, {logFile:failedLog}),/exit 17.*Log:[\s\S]*fixture prerequisite failed/);
    taskExitCode=0;
    missingPrerequisites='python312-pip';busyPrerequisites=true;
    choices.push('Install MCP4SAS for this computer','Choose an existing Cygwin Perl');dialogs.push(portable);
    const tasksBeforeBusyCheck=tasks.length;
    await commands.get('mcp4sas.setup')();
    assert.match(errors.at(-1),/python312-pip.*Close Cygwin/);
    assert.equal(tasks.length,tasksBeforeBusyCheck,'missing packages with active sessions cannot start an installer task');
    vscode.env.remoteName = 'ssh-remote';
    await api.configureCygwinTerminal(portable, true);
    assert.equal(settings.get('defaultProfile.windows'), 'My existing shell', 'remote settings are untouched');
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});
