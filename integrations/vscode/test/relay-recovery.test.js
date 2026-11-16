'use strict';
const {test}=require('node:test'),assert=require('node:assert/strict');
const http=require('node:http');
const fs=require('node:fs'),os=require('node:os'),path=require('node:path'),cp=require('node:child_process');
const {post,failureDetails}=require('../src/relay');
test('a failure before forwarding permits a checked direct-runner retry',()=>{
  const request={method:'tools/call',params:{name:'run_sas_codes_or_files_in_ODA',arguments:{sas_codes_or_file:'proc print;run;'}}};
  const result=failureDetails(request,false);
  assert.equal(result.safe_to_retry_via_runner,true);
  assert.match(result.recovery,/No tool request was sent/);
  assert.equal(failureDetails(request,true).safe_to_retry_via_runner,false);
  assert.match(failureDetails(request,true).recovery,/do not automatically resubmit/);
  assert.equal(failureDetails({...request,params:{...request.params,arguments:{pid:123}}},false).safe_to_retry_via_runner,false);
});
test('an initial setup failure returns a recoverable error without starting SAS',async()=>{
  const dir=fs.mkdtempSync(path.join(os.tmpdir(),'mcp4sas-relay-failure-'));
  try {
    for(const name of ['relay.js','routing.js'])fs.copyFileSync(path.join(__dirname,'../src',name),path.join(dir,name));
    fs.writeFileSync(path.join(dir,'core.js'),"exports.assertRepo=()=>{throw Error('Fixture runtime is unavailable');};");
    fs.writeFileSync(path.join(dir,'runtime.json'),JSON.stringify({repo:dir,cwd:dir}));
    const request={jsonrpc:'2.0',id:1,method:'tools/call',params:{name:'run_sas_codes_or_files_in_ODA',arguments:{sas_codes_or_file:'fixture'}}};
    const result=cp.spawnSync(process.execPath,[path.join(dir,'relay.js'),'--config',path.join(dir,'runtime.json')],{input:JSON.stringify(request)+'\n',encoding:'utf8',timeout:10000});
    assert.equal(result.status,0,result.stderr);
    const reply=JSON.parse(result.stdout);
    assert.equal(reply.id,1);
    assert.equal(reply.error.data.request_forwarded,false);
    assert.equal(reply.error.data.safe_to_retry_via_runner,true);
  } finally {await fs.promises.rm(dir,{recursive:true,force:true,maxRetries:5,retryDelay:100});}
});
test('a slow accepted HTTP request times out without replaying it',async()=>{
  let requests=0;
  const sockets=new Set();
  const server=http.createServer((req,res)=>{requests++;req.resume();/* Simulate a lost/slow reply after acceptance. */});
  server.on('connection',s=>{sockets.add(s);s.on('close',()=>sockets.delete(s));});
  await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
  try {
    await assert.rejects(post(server.address().port,{jsonrpc:'2.0',id:1,method:'tools/call'},150),/SAS job may still be running/);
    assert.equal(requests,1,'only one tool request reaches the server');
  } finally {
    for(const socket of sockets)socket.destroy();
    await new Promise(resolve=>server.close(resolve));
  }
});
