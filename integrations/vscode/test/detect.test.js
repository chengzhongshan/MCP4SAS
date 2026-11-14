'use strict';
const {test}=require('node:test'),assert=require('node:assert/strict');
const d=require('../src/detect');
function fakeFs(files=[],directories=[],metadata={}) {
 const names=new Set(files),dirs=new Set(directories);
 return {existsSync:p=>names.has(p)||dirs.has(p),statSync(p){if(!names.has(p))throw Error('missing');return{isFile:()=>true};},readdirSync(p){return [...dirs].filter(x=>x.startsWith(p+'\\')&&!x.slice(p.length+1).includes('\\')).map(x=>({name:x.slice(p.length+1),isDirectory:()=>true}));},readFileSync(p){if(!(p in metadata))throw Error('not metadata');return metadata[p];}};
}
test('Windows finds a native Conda environment, installed SAS and all three external JARs',()=>{
 const names=['C:\\Users\\reader\\anaconda3\\python.exe','C:\\SASHome\\SASFoundation\\9.4\\sas.exe',...d.JARS.map(n=>'C:\\Users\\reader\\Downloads\\SAS-ODA-JarFiles\\'+n)];
 const r=d.discoveryPaths({repo:'C:\\project'},{platform:'win32',home:'C:\\Users\\reader',env:{SAS_EXECUTABLE:names[1]},fs:fakeFs(names)});
 assert.deepEqual(r.python,[names[0]]);assert.deepEqual(r.sas,[names[1]]);assert.equal(r.jarDirs.length,1);
});
test('an incomplete JAR folder is not advertised as ready',()=>{
 const r=d.discoveryPaths({repo:'C:\\project'},{platform:'win32',home:'C:\\Users\\reader',env:{},fs:fakeFs(['C:\\Users\\reader\\Downloads\\SAS-ODA-JarFiles\\sas.rutil.jar'])});assert.deepEqual(r.jarDirs,[]);
});
test('macOS never advertises a native local SAS executable',()=>{
 const r=d.discoveryPaths({repo:'/project'},{platform:'darwin',home:'/home/reader',env:{SAS_EXECUTABLE:'/sas'},fs:fakeFs(['/sas','/usr/bin/python3'])});assert.deepEqual(r.sas,[]);assert.ok(r.python.includes('/usr/bin/python3'));
});
test('Linux honors a nonstandard SAS executable and project environment',()=>{
 const r=d.discoveryPaths({repo:'/project'},{platform:'linux',home:'/home/reader',env:{SAS_EXECUTABLE:'/apps/licensed-sas'},fs:fakeFs(['/apps/licensed-sas','/project/.venv-pipeline/bin/python'])});assert.deepEqual(r.sas,['/apps/licensed-sas']);assert.equal(r.python[0],'/project/.venv-pipeline/bin/python');
});
test('Cygwin symlinks that Windows cannot stat are probed through Bash with literal arguments',async()=>{
 const managed='C:\\project\\.venv-pipeline\\bin\\python';const calls=[];
 const r=await d.detect({repo:'C:\\project',perl:'C:\\selected\\bin\\perl.exe'},{platform:'win32',home:'C:\\reader',env:{},skipLauncher:true,fs:fakeFs([],['C:\\project\\.venv-pipeline\\bin']),async run(command,args){calls.push({command,args});if(command.endsWith('cygpath.exe'))return '/cygdrive/c/project/.venv-pipeline/bin/python';assert.ok(command.endsWith('bash.exe'));assert.equal(args[3],'exec "$@"');return 'MCP4SAS_DETECT_JSON='+JSON.stringify({python:'/cygdrive/c/project/.venv-pipeline/bin/python',platform:'cygwin',saspy:true,com:false,missing_jars:[]});}});
 assert.equal(r.oda.candidate,managed);assert.equal(calls.length,2);
});
test('broken Python is skipped without starting SAS or reading credentials',async()=>{
 const files=['/project/.venv-pipeline/bin/python','/usr/bin/python3'];let calls=0;
 const r=await d.detect({repo:'/project'},{platform:'linux',home:'/reader',env:{},fs:fakeFs(files),async run(command,args){calls++;assert.equal(args[0],'-c');assert.ok(!args[1].includes('SASsession'));assert.ok(!args[1].includes('authinfo'));if(command===files[0])throw Error('broken');return 'warning\nMCP4SAS_DETECT_JSON='+JSON.stringify({python:files[1],platform:'linux',saspy:true,com:false,missing_jars:[]});}});assert.equal(r.oda.candidate,files[1]);assert.equal(calls,2);
});
test('Windows Store launcher stubs are excluded',()=>{
 const stub='C:\\Users\\reader\\AppData\\Local\\Microsoft\\WindowsApps\\python.exe';const r=d.discoveryPaths({repo:'C:\\project'},{platform:'win32',home:'C:\\reader',env:{PATH:'C:\\Users\\reader\\AppData\\Local\\Microsoft\\WindowsApps'},fs:fakeFs([stub])});assert.deepEqual(r.python,[]);
});
test('switching from local SAS to ODA restores detected Cygwin Python and drops local-only config',()=>{
 const r=d.configuredTarget({saspyCfgname:'winlocal_com',saspyCfgfile:'private-local.py',python:'native.exe'},{oda:{platform:'cygwin',candidate:'C:\\venv\\bin\\python',python:'/cygdrive/c/venv/bin/python'}},'oda');assert.equal(r.python,'/cygdrive/c/venv/bin/python');assert.equal(r.saspyCfgname,'oda');assert.equal(r.saspyCfgfile,undefined);
});
test('existing IOM profile is retained; an absent local dependency never silently switches to ODA',()=>{
 const old={saspyCfgname:'winlocal',saspyCfgfile:'my-config.py'};
 const r=d.configuredTarget(old,{platform:'win32',local:{candidate:'python.exe'},sas:'sas.exe'},'local');assert.equal(r.saspyCfgname,'winlocal');assert.equal(r.saspyCfgfile,'my-config.py');assert.throws(()=>d.configuredTarget(old,{oda:{candidate:'oda-python'}},'local'),/Local SAS support/);
});
test('malformed probe output is rejected',()=>{assert.throws(()=>d.parseProbe('not-json'));assert.throws(()=>d.parseProbe('MCP4SAS_DETECT_JSON={}'));});
