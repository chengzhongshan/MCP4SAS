'use strict';
const {test}=require('node:test'),assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path'),os=require('node:os'),vm=require('node:vm');
const {createRequire}=require('node:module'),{EventEmitter}=require('node:events');
const guide=require('../src/setup-guide');
test('setup page escapes log text and explains SAS download, visible waits and final verification',()=>{
  const html=guide.page({cygwin:{status:'running',detail:'<script>not executable</script>'}},'<img src=x>','test-nonce');
  assert.ok(html.includes('&lt;script&gt;not executable&lt;/script&gt;'));
  assert.ok(html.includes('&lt;img src=x&gt;'));
  assert.match(html,/default-src 'none'/);assert.match(html,/nonce-test-nonce/);
  for(const text of ['more than five minutes','Select downloaded ZIP or folder','Sign in with your own SAS Profile','sas.rutil.nls.jar','Test selected SAS'])assert.ok(html.includes(text),text);
  assert.equal(guide.elapsed(0,365000),'6m 5s');
});
test('folder continuation is limited to the chosen folder and an unexpired user request',()=>{
  const p={folder:'C:\\Users\\reader\\SAS',created:1000};
  assert.equal(guide.pendingMatches(p,[{uri:{fsPath:'c:/users/reader/SAS'}}],2000),true);
  assert.equal(guide.pendingMatches(p,[{uri:{fsPath:'C:/other'}}],2000),false);
  assert.equal(guide.pendingMatches(p,[{uri:{fsPath:p.folder}}],86402000),false);
  assert.equal(guide.pendingMatches(p,[{uri:{fsPath:p.folder}}],500),false);
});
async function fixture(options={}) {
  const root=fs.mkdtempSync(path.join(os.tmpdir(),'mcp4sas-onboarding-'));
  const extensionPath=path.resolve(__dirname,'..'),commands=new Map(),state=new Map(options.pending?[['pendingSetup',options.pending]]:[]),calls=[],reports=[],panels=[];
  let pulse,now=0;
  const disposable=()=>({dispose(){}});
  const workspace={isTrusted:options.trusted!==false,workspaceFolders:options.folders||[],getConfiguration:()=>({get:()=>false})};
  const vscode={workspace,env:{},Uri:{file:fsPath=>({fsPath}),parse:value=>value},ViewColumn:{One:1},ProgressLocation:{Notification:1},EventEmitter:class{event(){}fire(){}dispose(){}},lm:{registerMcpServerDefinitionProvider:disposable},
    commands:{registerCommand(id,fn){commands.set(id,fn);return disposable();},async executeCommand(...args){calls.push(args);}},
    window:{createOutputChannel:()=>({appendLine(){},append(){},show(){},dispose(){}}),async withProgress(_,fn){return fn({report:r=>reports.push(r.message)});},async showQuickPick(){calls.push(['quickpick']);},async showInformationMessage(){return 'Choose Project Folder';},async showOpenDialog(){return [{fsPath:root}];},showErrorMessage(){},createWebviewPanel(){const panel={reveal(){},onDidDispose:disposable,webview:{html:'',onDidReceiveMessage:disposable}};panels.push(panel);return panel;}}};
  const realRequire=createRequire(path.join(extensionPath,'src/extension.js')),module={exports:{}};
  vm.runInNewContext(fs.readFileSync(path.join(extensionPath,'src/extension.js'),'utf8'),{module,__dirname:path.join(extensionPath,'src'),process:{platform:'win32',execPath:process.execPath,env:{LOCALAPPDATA:root,ProgramFiles:root}},Date:class extends Date{static now(){return now;}},AbortSignal,Buffer,
    fetch:async()=>({ok:true,async arrayBuffer(){return Buffer.from('fixture executable');}}),
    require(name){
      if(name==='vscode')return vscode;
      if(name==='./setup-guide')return {...guide,elapsed:start=>guide.elapsed(start,now),pendingMatches:(pending,folders)=>guide.pendingMatches(pending,folders,now)};
      if(name==='node:timers')return {setInterval(fn){pulse=fn;return 1;},clearInterval(){pulse=undefined;}};
      if(name==='node:fs')return {...fs,existsSync:file=>String(file).startsWith(root)&&fs.existsSync(file)};
      if(name==='node:child_process')return {spawn(command,args,opts){calls.push(['spawn',command,args,opts]);const child=new EventEmitter();child.stdout=new EventEmitter();child.stderr=new EventEmitter();queueMicrotask(()=>{now=365000;pulse();child.emit('close',0);});return child;}};
      return realRequire(name);
    }});
  const api=await module.exports.activate({extensionPath,subscriptions:[],globalStorageUri:{fsPath:path.join(root,'storage')},globalState:{get:key=>state.get(key),async update(key,value){state.set(key,value);}}});
  return {api,root,commands,state,calls,reports,panels,vscode,cleanup(){fs.rmSync(root,{recursive:true,force:true});}};
}
test('empty-window setup opens a writable folder before any installation and saves continuation',async()=>{
  const f=await fixture();
  try {
    assert.equal(await f.api.ensureSetupWorkspace(),false);
    assert.equal(f.calls[0][0],'vscode.openFolder');
    assert.equal(f.calls[0][1].fsPath,f.root);
    assert.equal(f.state.get('pendingSetup').folder,f.root);
    assert.equal(f.calls.some(c=>c[0]==='spawn'),false,'no installer before opening and trusting the project');
  } finally {f.cleanup();}
});
test('the official Cygwin progress window stays visible and VS Code reports a six-minute wait',async()=>{
  const f=await fixture();
  try {
    f.api.showSetupGuide();
    await f.api.bootstrapCygwin(undefined,'bash,perl');
    const launch=f.calls.find(c=>c[0]==='spawn');
    assert.equal(launch[3].windowsHide,false);
    assert.ok(launch[2].includes('-q'),'retains the established unattended progress mode');
    assert.ok(launch[2].includes('--no-write-registry'));
    assert.ok(f.reports.some(s=>s.includes('6m 5s elapsed')));
    assert.match(f.panels[0].webview.html,/finished in 6m 5s/);
  } finally {f.cleanup();}
});
test('untrusted projects do not trigger or consume saved setup continuation',async()=>{
  const f=await fixture({trusted:false,pending:{folder:'test',created:0},folders:[{uri:{fsPath:'test'}}]});
  try {await Promise.resolve();assert.equal(f.state.get('pendingSetup').folder,'test');assert.equal(f.calls.length,0);} finally {f.cleanup();}
});
test('trusted matching folder resumes once after VS Code reload',async()=>{
  const f=await fixture({pending:{folder:'test',created:0},folders:[{uri:{fsPath:'test'}}]});
  try {await new Promise(resolve=>setImmediate(resolve));assert.equal(f.state.get('pendingSetup'),undefined);assert.equal(f.calls.filter(c=>c[0]==='quickpick').length,1);} finally {f.cleanup();}
});
test('repeated Quick Setup clicks share one installation flow',async()=>{
  const f=await fixture({folders:[{uri:{fsPath:'test'}}]});
  try {
    let release,count=0;
    f.vscode.window.showQuickPick=()=>{count++;return new Promise(resolve=>{release=resolve;});};
    const first=f.commands.get('mcp4sas.setup')();await new Promise(resolve=>setImmediate(resolve));
    const second=f.commands.get('mcp4sas.setup')();release(undefined);
    await Promise.all([first,second]);assert.equal(count,1);
  } finally {f.cleanup();}
});
