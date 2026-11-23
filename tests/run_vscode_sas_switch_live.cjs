// Opt-in, real MCP relay/SAS check. Never changes the installed user's selection.
// node tests/run_vscode_sas_switch_live.cjs --runtime PATH --out NEW_DIR [--live] [--iom-config PATH]
'use strict';
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process'),readline=require('node:readline'),assert=require('node:assert/strict');
const core=require('../integrations/vscode/src/core'),detect=require('../integrations/vscode/src/detect');
const option=n=>{const i=process.argv.indexOf(n);return i<0?undefined:process.argv[i+1];};
const root=path.resolve(__dirname,'..');
const runtime=option('--runtime'),destination=option('--out');
if(!runtime||!destination)throw Error('Required: --runtime PATH --out NEW_DIR; add --live for SAS execution.');
const original=fs.readFileSync(runtime),saved=JSON.parse(original),out=path.resolve(destination);
const session='vscode_switch_'+process.pid;
let child,id=0,diagnostics='',ownsOutput=false,report;
const pending=new Map(),records=[],checks=[],ownedTargets=[];
const body=r=>(r.content||[]).map(c=>c.text||'').join('\n');
function request(method,params={}) {
 const message={jsonrpc:'2.0',id:++id,method,params};records.push({sent:message});
 return new Promise((resolve,reject)=>{const timer=setTimeout(()=>{pending.delete(message.id);reject(Error('RPC timeout'));},210000);pending.set(message.id,{resolve,reject,timer});child.stdin.write(JSON.stringify(message)+'\n');});
}
async function finish(result) {
 const pid=body(result).match(/^PID:\s*(\d+)/m)?.[1];
 const until=Date.now()+180000;
 while(!/^STATUS: (COMPLETE|FAILED)/m.test(body(result))&&Date.now()<until) {
  assert.ok(pid,'job must provide PID');await new Promise(r=>setTimeout(r,2000));
  result=await request('tools/call',{name:'run_sas_codes_or_files_in_ODA',arguments:{pid:Number(pid)}});
 }
 return result;
}
const positive='proc means data=sashelp.class noprint;var Age;output out=work.check_age n=n nmiss=missing min=minimum max=maximum;run;data _null_;set work.check_age;put "SWITCH_VALUES " n= missing= minimum= maximum=;put "SWITCH_PLATFORM &sysscp";run;';
function submit(code,extra={}) { return request('tools/call',{name:'run_sas_codes_or_files_in_ODA',arguments:{sas_codes_or_file:code,session_id:session,...extra}}); }
async function checked(name,result,platform,negative=false) {
 result=await finish(result);const text=body(result);
 assert.match(text,new RegExp('^STATUS: '+(negative?'FAILED':'COMPLETE'),'m'));
 if(negative)assert.match(text,/ERROR: File WORK\.SWITCH_INTENTIONALLY_MISSING\.DATA does not exist\./);
 else {
  assert.match(text,/^SWITCH_VALUES n=19 missing=0 minimum=11 maximum=16\s*$/m);
  assert.match(text,new RegExp('^SWITCH_PLATFORM '+platform,'m'));
  assert.ok(!/^\s*ERROR(?:\s+\d+-\d+)?:/m.test(text));
 }
 const warnings=(text.match(/^WARNING:/gm)||[]).length;
 checks.push({name,status:'PASS',warnings});fs.writeFileSync(path.join(out,name+'.txt'),text);console.log(JSON.stringify(checks.at(-1)));
 return text;
}
(async()=>{
 const found=await detect.detect(saved);
 if(!found.oda||!found.local)throw Error('This test needs an installed, configured ODA environment and local SAS. Linux hosts exercise Linux STDIO; Windows hosts exercise native COM.');
 if(!process.argv.includes('--live')){console.log(JSON.stringify({plan_only:true,platform:found.platform,local_sas_detected:!!found.sas,oda_python_found:!!found.oda,local_python_found:!!found.local,sequence:['ODA pending job','local positive/negative','poll original ODA job','ODA positive/negative','stale-target rejection'],iom_requested:!!option('--iom-config')},null,2));return;}
 if(fs.existsSync(out))throw Error('Use a new output directory to preserve earlier evidence.');
 fs.mkdirSync(out,{recursive:true});
 ownsOutput=true;
 const privateConfig=path.join(out,'runtime.json');
 const oda={...detect.configuredTarget(saved,found,'oda'),cwd:out,sessionPort:await core.allocateSessionPort()};
 ownedTargets.push(oda);
 const local={...detect.configuredTarget(oda,found,'local'),repo:oda.repo,cwd:out,sessionPort:await core.allocateSessionPort()};
 ownedTargets.push(local);
 if(!local.saspyCfgfile){
   local.saspyCfgfile=path.join(out,'local-sas.py');
   fs.writeFileSync(local.saspyCfgfile,found.platform==='win32'?"SAS_config_names=['winlocal_com']\nSAS_config_options={'lock_down':False,'prompt':False}\nwinlocal_com={'provider':'sas.iomprovider','encoding':'windows-1252'}\n":`SAS_config_names=['linuxlocal']\nSAS_config_options={'lock_down':False,'prompt':False}\nlinuxlocal={'saspath':${JSON.stringify(found.sas)},'encoding':'utf-8'}\n`);
 }
 const choose=config=>fs.writeFileSync(privateConfig,JSON.stringify(config,null,2));
 choose(oda);
 child=cp.spawn(process.execPath,[path.join(root,'integrations/vscode/src/relay.js'),'--config',privateConfig],{windowsHide:true});
 child.stderr.on('data',b=>diagnostics+=b);
 child.on('exit',code=>{for(const p of pending.values())p.reject(Error('Relay exited '+code));});
 const lines=readline.createInterface({input:child.stdout});
 lines.on('line',line=>{const reply=JSON.parse(line);records.push({received:reply});const p=pending.get(reply.id);if(p){clearTimeout(p.timer);pending.delete(reply.id);if(reply.error)p.reject(Error(reply.error.message));else p.resolve(reply.result);}});
 await request('initialize',{protocolVersion:'2024-11-05',capabilities:{},clientInfo:{name:'MCP4SAS target switch live test',version:'0.1.5'}});
 child.stdin.write(JSON.stringify({jsonrpc:'2.0',method:'notifications/initialized'})+'\n');
 const first=await submit(positive);
 choose(local);
 const tools=await request('tools/list');assert.equal(tools.tools.find(t=>t.name==='run_sas_codes_or_files_in_ODA').inputSchema.properties.saspy_cfgname.default,local.saspyCfgname);
 await checked('local-positive',await submit(positive),found.platform==='win32'?'WIN':'LIN');
 await checked('oda-job-polled-after-local-switch',first,'LIN');
 await checked('local-negative',await submit('proc print data=work.switch_intentionally_missing;run;'),null,true);
 choose(oda);
 await checked('oda-positive-after-switch-back',await submit(positive),'LIN');
 await checked('oda-negative',await submit('proc print data=work.switch_intentionally_missing;run;'),null,true);
 await assert.rejects(submit(positive,{saspy_cfgname:local.saspyCfgname}),/No SAS code was submitted/);
 checks.push({name:'stale-target-rejected-before-submission',status:'PASS'});
 await checked('oda-after-negative-recovery',await submit(positive),'LIN');
 const iomFile=option('--iom-config');
 if(iomFile) {
   assert.equal(found.platform,'win32');
   const iom={...local,saspyCfgname:'winlocal',saspyCfgfile:path.resolve(iomFile),sessionPort:await core.allocateSessionPort()};ownedTargets.push(iom);choose(iom);
   await checked('windows-iom-positive',await submit('data work.switch_saved;value=42;run;'+positive),'WIN');
   const work=await checked('windows-iom-persistent-work',await submit('data _null_;set work.switch_saved;put "SWITCH_PERSIST " value=;run;'+positive),'WIN');
   assert.match(work,/^SWITCH_PERSIST value=42\s*$/m);
 }
 // The finally block closes only this test's named persistent sessions.
 const ended=new Promise(resolve=>child.once('exit',resolve));child.stdin.end();assert.equal(await ended,0);
 assert.deepEqual(fs.readFileSync(runtime),original,'installed user selection must remain unchanged');
 report={checks,platform:found.platform,profile_local:local.saspyCfgname,complete:true,installed_config_unchanged:true,scope:'Real stdio/HTTP MCP relay and installed SAS runtime. No interactive AI turn. Linux execution requires running this harness on a licensed Linux SAS host.'};
})().catch(e=>{console.error(e);if(ownsOutput)fs.writeFileSync(path.join(out,'failure.json'),JSON.stringify({error:e.message,checks},null,2));process.exitCode=1;}).finally(async()=>{
 for(const p of pending.values())clearTimeout(p.timer);
 if(child&&child.exitCode===null)child.kill();
 for(const config of ownedTargets)try {
   // The legacy Perl kill switch can stop unrelated sessions. Never use it
   // from a test: address only a fresh helper allocated above, then its PID.
   assert.notEqual(config.sessionPort,65055,'never stop the user shared helper');
   const net=require('node:net');
   const owner=await new Promise((resolve,reject)=>{
     const socket=net.createConnection({host:'127.0.0.1',port:config.sessionPort});let buffer=Buffer.alloc(0);
     socket.setTimeout(10000,()=>socket.destroy(Error('helper ping timeout')));
     socket.on('error',e=>e.code==='ECONNREFUSED'?resolve(null):reject(e));
     socket.on('connect',()=>{const body=Buffer.from(JSON.stringify({cmd:'ping'})),header=Buffer.alloc(8);header.writeBigUInt64BE(BigInt(body.length));socket.write(Buffer.concat([header,body]));});
     socket.on('data',data=>{buffer=Buffer.concat([buffer,data]);if(buffer.length>=8){const size=Number(buffer.readBigUInt64BE());if(buffer.length>=8+size){socket.end();resolve(JSON.parse(buffer.subarray(8,8+size)));}}});
   });
   if(owner?.status==='ok'&&Number.isInteger(owner.pid)) {
     if(process.platform==='win32')await core.run(path.join(process.env.SystemRoot||'C:/Windows','System32/taskkill.exe'),['/PID',String(owner.pid),'/T','/F'],{timeout:30000});
     else process.kill(owner.pid,'SIGTERM');
     checks.push({name:'owned-helper-cleanup-'+config.saspyCfgname,status:'PASS',port:config.sessionPort,pid:owner.pid});
   }
 }catch(e){checks.push({name:'session-cleanup-'+config.saspyCfgname,status:'FAILED',error:e.message});process.exitCode=1;}
 if(ownsOutput){
  fs.writeFileSync(path.join(out,'mcp-records.json'),JSON.stringify(records,null,2));fs.writeFileSync(path.join(out,'relay-stderr.txt'),diagnostics);
  fs.writeFileSync(path.join(out,'execution.json'),JSON.stringify({...report,checks,complete:!!report&&process.exitCode!==1&&checks.every(c=>c.status==='PASS'),installed_config_unchanged:fs.readFileSync(runtime).equals(original)},null,2));
 }
});
