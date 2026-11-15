'use strict';
const {test}=require('node:test'),assert=require('node:assert/strict');
const fs=require('node:fs'),os=require('node:os'),path=require('node:path'),cp=require('node:child_process'),readline=require('node:readline');
test('an already connected relay switches targets while an earlier job still polls its original backend',async()=>{
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'mcp4sas-relay-switch-'));
 let child;const waiters=new Map();let next=0,stderr='';
 try {
  for(const name of ['relay.js','routing.js'])fs.copyFileSync(path.join(__dirname,'../src',name),path.join(dir,name));
  // Fake only the SAS runtime, not the real relay, JSON transport or HTTP route.
  fs.writeFileSync(path.join(dir,'core.js'),`exports.assertRepo=()=>{};exports.toPosix=async x=>x;exports.runtimeEnvironment=async c=>({...process.env,TEST_PROFILE:c.saspyCfgname});`);
  fs.writeFileSync(path.join(dir,'server.pl'),`
const http=require('node:http');const port=Number(process.argv.at(-1).split(':').at(-1));
const server=http.createServer((req,res)=>{let text='';req.on('data',b=>text+=b);req.on('end',()=>{
const q=JSON.parse(text);let result={};if(q.method==='initialize')result={serverInfo:{name:'fake-SAS'}};
if(q.method==='tools/list')result={tools:[{name:'run_sas_codes_or_files_in_ODA',inputSchema:{properties:{saspy_cfgname:{type:'string'}}}}]};
if(q.method==='tools/call')result={content:[{type:'text',text:'PID: '+process.pid+'\\nSTATUS: '+(q.params.arguments.pid?'COMPLETE':'RUNNING')+'\\nBACKEND='+process.env.TEST_PROFILE+'\\nARG='+q.params.arguments.saspy_cfgname}]};
res.setHeader('Content-Type','application/json');res.end(JSON.stringify({jsonrpc:'2.0',id:q.id,result}));});});server.listen(port,'127.0.0.1');`);
  const file=path.join(dir,'runtime.json');
  const config={repo:dir,cwd:dir,perl:process.execPath,saspyCfgname:'oda',sessionPort:41001};
  fs.writeFileSync(file,JSON.stringify(config));
  child=cp.spawn(process.execPath,[path.join(dir,'relay.js'),'--config',file],{windowsHide:true});
  child.stderr.on('data',b=>stderr+=b);
  child.on('exit',code=>{for(const p of waiters.values())p.reject(Error('Relay exited '+code+': '+stderr));});
  const lines=readline.createInterface({input:child.stdout});
  lines.on('line',line=>{const reply=JSON.parse(line),pending=waiters.get(reply.id);if(pending){clearTimeout(pending.timer);waiters.delete(reply.id);pending.resolve(reply);}});
  const request=(method,params={})=>new Promise((resolve,reject)=>{const id=++next,timer=setTimeout(()=>reject(Error('RPC timeout '+stderr)),15000);waiters.set(id,{resolve,reject,timer});child.stdin.write(JSON.stringify({jsonrpc:'2.0',id,method,params})+'\n');});
  const tools=()=>request('tools/list');
  const call=(args={})=>request('tools/call',{name:'run_sas_codes_or_files_in_ODA',arguments:args});
  const text=r=>r.result.content.map(c=>c.text).join('\n');
  await request('initialize');
  const started=await call({sas_codes_or_file:'fake code'}),pid=Number(text(started).match(/PID: (\d+)/)[1]);
  assert.match(text(started),/BACKEND=oda/);assert.match(text(started),/ARG=oda/);
  fs.writeFileSync(file,JSON.stringify({...config,saspyCfgname:'linuxlocal',sessionPort:41002}));
  assert.equal((await tools()).result.tools[0].inputSchema.properties.saspy_cfgname.default,'linuxlocal');
  const local=await call({sas_codes_or_file:'fake code'});assert.match(text(local),/BACKEND=linuxlocal/);assert.match(text(local),/ARG=linuxlocal/);
  const polled=await call({pid});assert.match(text(polled),/BACKEND=oda/);assert.match(text(polled),/STATUS: COMPLETE/);
  const rejected=await call({sas_codes_or_file:'fake code',saspy_cfgname:'oda'});assert.match(rejected.error.message,/No SAS code was submitted/);
  fs.writeFileSync(file,JSON.stringify(config));
  const returned=await call({sas_codes_or_file:'fake code'});assert.match(text(returned),/BACKEND=oda/);
  assert.equal(Number(text(returned).match(/PID: (\d+)/)[1]),pid,'returning to the unchanged ODA target reuses its backend');
  const ended=new Promise(resolve=>child.once('exit',resolve));child.stdin.end();assert.equal(await ended,0);
 } finally {
  for(const p of waiters.values())clearTimeout(p.timer);
  if(child&&child.exitCode===null)child.kill();
  await fs.promises.rm(dir,{recursive:true,force:true,maxRetries:5,retryDelay:100});
 }
});
