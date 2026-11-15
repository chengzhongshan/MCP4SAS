'use strict';
const {test}=require('node:test'),assert=require('node:assert/strict');
const discovery=require('../src/detect'),core=require('../src/core'),routing=require('../src/routing');
for(const [platform,profile,python,sas] of [['win32','winlocal_com','C:/python.exe','C:/SAS/sas.exe'],['linux','linuxlocal','/usr/bin/python3','/licensed/sas']]) {
  test(`${platform}: ODA/local/ODA keeps independent interpreter, configuration and session port`,()=>{
    const oda={repo:'/repo',python:'/oda/python',saspyCfgname:'oda',saspyCfgfile:'/private/oda.py',sessionPort:41001};
    const found={platform,local:{candidate:python},oda:{candidate:'/oda/python',platform:'linux'},sas};
    let local=discovery.configuredTarget(oda,found,'local');
    assert.equal(local.saspyCfgname,profile);assert.equal(local.saspyCfgfile,undefined);
    local={...local,saspyCfgfile:'/private/local.py',sessionPort:41002};
    local.targets=discovery.rememberTargets(local);
    const returned=discovery.configuredTarget(local,found,'oda');
    assert.equal(returned.python,oda.python);assert.equal(returned.saspyCfgfile,oda.saspyCfgfile);assert.equal(returned.sessionPort,41001);
    const again=discovery.configuredTarget(returned,found,'local');
    assert.equal(again.saspyCfgfile,'/private/local.py');assert.equal(again.sessionPort,41002);
    assert.notEqual(routing.key(local),routing.key(returned));
    assert.notEqual(routing.key(local),routing.key({...local,sasExecutable:sas+'-new'}),'a changed SAS executable cannot reuse the old backend');
    assert.deepEqual(oda,{repo:'/repo',python:'/oda/python',saspyCfgname:'oda',saspyCfgfile:'/private/oda.py',sessionPort:41001});
  });
  test(`${platform}: active target is supplied without trusting stale assistant arguments`,()=>{
    const call={jsonrpc:'2.0',id:1,method:'tools/call',params:{name:'run_sas_codes_or_files_in_ODA',arguments:{sas_codes_or_file:'proc print;run;'}}};
    const config={saspyCfgname:profile};
    assert.equal(routing.submission(call,config).params.arguments.saspy_cfgname,profile);
    assert.equal(call.params.arguments.saspy_cfgname,undefined);
    assert.throws(()=>routing.submission({...call,params:{...call.params,arguments:{saspy_cfgname:'oda'}}},config),/No SAS code was submitted/);
  });
}
test('target selection clears an inherited incompatible SASPy file but retains unrelated settings',()=>{
  const base={SASPY_CFGFILE:'/old/local.py',HTTPS_PROXY:'private-proxy'};
  const env=core.connectionEnvironment({saspyCfgname:'oda'},base);
  assert.equal(env.SASPY_CFGFILE,undefined);assert.equal(env.HTTPS_PROXY,base.HTTPS_PROXY);assert.equal(base.SASPY_CFGFILE,'/old/local.py');
});
test('polling a job ignores the new target and keeps the backend that owns its PID',()=>{
  const jobs=new Map(),backend={port:1234};
  const call={method:'tools/call',params:{name:'run_sas_codes_or_files_in_ODA',arguments:{}}};
  routing.rememberJob(call,{result:{content:[{text:'PID: 9876\nSTATUS: RUNNING'}]}},backend,jobs);
  const poll={method:'tools/call',params:{name:'run_sas_codes_or_script_in_ODA',arguments:{pid:9876,saspy_cfgname:'oda'}}};
  assert.equal(jobs.get(routing.jobId(poll)),backend);
  assert.equal(routing.submission(poll,{saspyCfgname:'linuxlocal'}),poll);
});
test('tool discovery identifies the current target without changing unrelated tools',()=>{
  const original={result:{tools:[{name:'run_sas_codes_or_files_in_ODA',inputSchema:{properties:{saspy_cfgname:{type:'string'}}}},{name:'unrelated'}]}};
  const reply=routing.describe(original,{saspyCfgname:'linuxlocal'});
  assert.equal(reply.result.tools[0].inputSchema.properties.saspy_cfgname.default,'linuxlocal');
  assert.match(reply.result.tools[0].description,/Selected VS Code SAS target: linuxlocal/);
  assert.equal(reply.result.tools[1],original.result.tools[1]);
  assert.equal(original.result.tools[0].inputSchema.properties.saspy_cfgname.default,undefined);
});
test('Windows COM defaults to one-shot and refuses an unsupported persistent request',()=>{
  const request={method:'tools/call',params:{name:'run_sas_codes_or_files_in_ODA',arguments:{sas_codes_or_file:'proc print;run;'}}};
  const config={saspyCfgname:'winlocal_com'};
  assert.equal(routing.submission(request,config).params.arguments.persistent,'false');
  assert.throws(()=>routing.submission({...request,params:{...request.params,arguments:{persistent:'true'}}},config),/creating thread/);
  const tools=routing.describe({result:{tools:[{name:request.params.name,inputSchema:{properties:{}}}]}},config);
  assert.equal(tools.result.tools[0].inputSchema.properties.persistent.default,'false');
});
