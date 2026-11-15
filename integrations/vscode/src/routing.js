'use strict';
// Request routing is separate from rendering/UI and can be tested without SAS.
const SASPY_TOOLS=new Set(['run_sas_codes_or_files_in_ODA','run_sas_codes_or_script_in_ODA']);
function key(config) {
  return JSON.stringify(['repo','perl','cwd','java','python','saspyCfgname','saspyCfgfile','sasExecutable','sessionPort'].map(k=>config[k]??null));
}
function submission(request, config) {
  if(request.method!=='tools/call'||!SASPY_TOOLS.has(request.params?.name)||request.params.arguments?.pid)return request;
  const profile=config.saspyCfgname||'oda',args=request.params.arguments||{};
  if(args.saspy_cfgname&&args.saspy_cfgname!==profile)throw Error(`Selected SAS target is ${profile}, but the request names ${args.saspy_cfgname}. Use MCP4SAS: Switch SAS Target or submit to ${profile}. No SAS code was submitted.`);
  if(args.saspy_cfgfile&&args.saspy_cfgfile!==config.saspyCfgfile)throw Error('The request uses a different SASPy configuration from the selected SAS target. Switch the target before submitting. No SAS code was submitted.');
  if(profile==='winlocal_com'&&args.persistent!==undefined&&!/^(false|0|no|off)$/i.test(String(args.persistent)))throw Error('Windows COM uses one-shot submissions because its workspace belongs to its creating thread. Use persistent=false and submit the complete SAS program, or use a configured Windows IOM profile for persistent sessions. No SAS code was submitted.');
  return {...request,params:{...request.params,arguments:{...args,saspy_cfgname:profile,...(profile==='winlocal_com'?{persistent:'false'}:{})}}};
}
function describe(response, config) {
  const profile=config.saspyCfgname||'oda';
  if(!Array.isArray(response.result?.tools))return response;
  const tools=response.result.tools.map(t=>{
    if(!SASPY_TOOLS.has(t.name))return t;
    const properties={...t.inputSchema?.properties,saspy_cfgname:{...t.inputSchema?.properties?.saspy_cfgname,default:profile}};
    if(profile==='winlocal_com')properties.persistent={...properties.persistent,default:'false'};
    const com=profile==='winlocal_com'?'Windows COM is one-shot: submit the complete program with persistent=false; WORK does not carry across calls. ':'';
    return {...t,description:`Selected VS Code SAS target: ${profile}. Omit saspy_cfgname to use this selection. ${com}Switch SAS Target in VS Code before choosing another target. ${t.description||''}`,
      inputSchema:{...t.inputSchema,properties}};
  });
  return {...response,result:{...response.result,tools}};
}
function jobId(request) { return request.method==='tools/call'&&request.params?.arguments?.pid?String(request.params.arguments.pid):null; }
function rememberJob(request,response,backend,jobs) {
  if(request.method!=='tools/call')return;
  const text=(response.result?.content||[]).map(c=>c.text||'').join('\n');
  const pid=text.match(/^PID:\s*(\d+)/m)?.[1];
  if(pid)jobs.set(pid,backend);
}
module.exports={key,submission,describe,jobId,rememberJob};
