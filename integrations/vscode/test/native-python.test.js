'use strict';
const {test}=require('node:test'),assert=require('node:assert/strict');
const fs=require('node:fs'),os=require('node:os'),path=require('node:path');
const native=require('../src/native-python');
function fixture(t, {base=true, broken=false, healthy=false, failInstall=false, failPip=false}={}) {
  const storage=fs.mkdtempSync(path.join(os.tmpdir(),'mcp4sas-native-test-'));
  t.after(()=>fs.rmSync(storage,{recursive:true,force:true}));
  const python=path.join(storage,'existing-conda','python.exe');
  const executable=path.join(storage,'native-saspy','Scripts','python.exe');
  const installed=path.join(storage,'python-runtime','python.exe');
  const good=new Set(base?[python]:[]),tasks=[];
  if(broken||healthy){fs.mkdirSync(path.dirname(executable),{recursive:true});fs.writeFileSync(executable,'old');}
  if(healthy)good.add(executable);
  const options={storage,config:{repo:storage},platform:'win32',found:{python:base?[{candidate:python,platform:'win32'}]:[],native:base?{candidate:python}:undefined},
    async run(command,args){if(!good.has(command))throw Error('missing base interpreter');if(args.includes(native.PROBE))return JSON.stringify({platform:'win32',version:[3,13],bits:64});return '';},
    async task(command,args){tasks.push({command,args});
      if(command==='powershell.exe'){if(failInstall)throw Error('download failed');good.add(installed);}
      else if(args.includes('venv')){fs.mkdirSync(path.dirname(executable),{recursive:true});fs.writeFileSync(executable,'new');good.add(executable);}
      else if(failPip)throw Error('pip failed');
    },
    async detect(config){return {local:{candidate:config.python,saspy:true}};}
  };
  return {options,storage,python,executable,installed,tasks};
}
test('no Python or winget: installs per-user CPython then an isolated verified SASPy environment',async t=>{
  const f=fixture(t,{base:false});const result=await native.ensure(f.options);
  assert.equal(f.tasks.length,3);assert.equal(f.tasks[0].command,'powershell.exe');
  assert.ok(f.tasks[0].args.includes(path.join(f.storage,'python-runtime')));
  assert.equal(f.tasks[1].command,f.installed);assert.equal(f.tasks[2].command,f.executable);
  assert.ok(f.tasks[2].args.includes('saspy'));assert.ok(f.tasks[2].args.includes('pywin32'));
  assert.equal(result.local.candidate,f.executable);
});
test('reuses working Conda without installing packages into its base environment',async t=>{
  const f=fixture(t);await native.ensure(f.options);
  assert.equal(f.tasks.length,2);assert.equal(f.tasks[0].command,f.python);
  assert.deepEqual(f.tasks[0].args.slice(0,2),['-m','venv']);assert.equal(f.tasks[1].command,f.executable);
});
test('broken managed venv is backed up and rebuilt using a working base',async t=>{
  const f=fixture(t,{broken:true});await native.ensure(f.options);
  const backups=fs.readdirSync(f.storage).filter(n=>n.startsWith('native-saspy.backup-'));
  assert.equal(backups.length,1);assert.equal(fs.readFileSync(path.join(f.storage,backups[0],'Scripts','python.exe'),'utf8'),'old');
  assert.equal(fs.readFileSync(f.executable,'utf8'),'new');
});
test('healthy managed venv is reused even without another discovered Python',async t=>{
  const f=fixture(t,{base:false,healthy:true});await native.ensure(f.options);
  assert.equal(f.tasks.length,1);assert.equal(f.tasks[0].command,f.executable);
});
test('failed bootstrap preserves broken environment and does not run pip',async t=>{
  const f=fixture(t,{base:false,broken:true,failInstall:true});await assert.rejects(native.ensure(f.options),/download failed/);
  assert.equal(fs.readFileSync(f.executable,'utf8'),'old');assert.equal(f.tasks.length,1);
});
test('pip failure cannot be advertised as ready',async t=>{
  const f=fixture(t,{failPip:true});await assert.rejects(native.ensure(f.options),/pip failed/);
});
test('rejects Cygwin, 32-bit, obsolete and unvalidated newer Python',async()=>{
  for(const data of [{platform:'cygwin',version:[3,12],bits:64},{platform:'win32',version:[3,13],bits:32},{platform:'win32',version:[3,9],bits:64},{platform:'win32',version:[3,14],bits:64}])
    assert.equal(await native.usable('python',async()=>JSON.stringify(data),'win32'),false);
});
