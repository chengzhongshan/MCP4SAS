// Real no-Conda/no-winget provisioning and broken-venv recovery. Opt-in only.
// node tests/run_native_windows_setup_live.cjs NEW_OUTPUT_DIRECTORY
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const native=require('../integrations/vscode/src/native-python'),core=require('../integrations/vscode/src/core'),discovery=require('../integrations/vscode/src/detect');
const out=path.resolve(process.argv[2]||'');
if(process.platform!=='win32'||!process.argv[2]||fs.existsSync(out))throw Error('Specify a new output directory on Windows. This runs a per-user CPython installer.');
fs.mkdirSync(out,{recursive:true});
const tasks=[],checks=[];
const config={repo:path.resolve(__dirname,'..'),perl:path.join(process.env.LOCALAPPDATA,'MCP4SAS/cygwin/bin/perl.exe'),saspyCfgname:'winlocal',sasExecutable:'C:\\Program Files\\SASHome\\SASFoundation\\9.4\\sas.exe'};
const storage=path.join(out,"Reader's native Python");
async function task(command,args,cwd){
 const index=tasks.length;tasks.push({command,args});console.log('START '+path.basename(command)+' '+args.slice(0,3).join(' '));
 try{const result=await core.run(command,args,{cwd,timeout:600000});fs.writeFileSync(path.join(out,'task-'+index+'.txt'),result);}
 catch(error){fs.writeFileSync(path.join(out,'task-'+index+'.txt'),error.message);throw error;}
}
async function execute(){
 const options={storage,config,found:{python:[]},run:core.run,task,detect:discovery.detect,log:console.log};
 const first=await native.ensure(options);
 const python=path.join(storage,'native-saspy/Scripts/python.exe');
 assert.equal(path.resolve(first.local.candidate),path.resolve(python));
 assert.equal(tasks[0].command,'powershell.exe');checks.push('real CPython install with no discovered Python or winget');
 const version=await core.run(python,['-I','-c','import sys,saspy,win32com.client; print(sys.version); print(saspy.__version__)']);
 fs.writeFileSync(path.join(out,'python-version.txt'),version);checks.push('native isolated Python, SASPy and pywin32 imports');
 const venvConfig=path.join(storage,'native-saspy/pyvenv.cfg');
 const original=fs.readFileSync(venvConfig,'utf8');
 fs.writeFileSync(venvConfig,original.replace(/^home = .*$/m,'home = C:\\MCP4SAS_intentionally_missing_base'));
 assert.equal(await native.usable(python,core.run,'win32'),false);checks.push('existing python.exe with broken base detected');
 const before=tasks.length;
 const second=await native.ensure(options);
 assert.equal(tasks.length,before+2,'working managed CPython is reused for venv repair');
 assert.equal(path.resolve(second.local.candidate),path.resolve(python));
 assert.equal(fs.readdirSync(storage).filter(n=>n.startsWith('native-saspy.backup-')).length,1);
 checks.push('broken venv retained and rebuilt without Conda or a second Python install');
 fs.writeFileSync(path.join(out,'runtime.json'),JSON.stringify({...config,cwd:out,python,saspyCfgfile:path.join(out,'local-iom.py')},null,2));
 fs.writeFileSync(path.join(out,'local-iom.py'),require('../integrations/vscode/src/local-profile').source(config));
}
execute().then(()=>{fs.writeFileSync(path.join(out,'result.json'),JSON.stringify({complete:true,checks,tasks},null,2));console.log('PASS: '+checks.join('; '));}).catch(error=>{fs.writeFileSync(path.join(out,'result.json'),JSON.stringify({complete:false,checks,tasks,error:error.stack},null,2));console.error(error);process.exitCode=1;});
