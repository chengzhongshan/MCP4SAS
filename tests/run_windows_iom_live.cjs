// Opt-in live MCP/SAS verification, using an isolated session-server port.
// node tests/run_windows_iom_live.cjs --runtime PATH --out NEW_DIR [--macros DIR] [--relay PATH]
'use strict';
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process'),rl=require('node:readline'),assert=require('node:assert/strict');
const core=require('../integrations/vscode/src/core');
const option=n=>{const i=process.argv.indexOf(n);return i<0?undefined:process.argv[i+1];};
const out=path.resolve(option('--out')||''),runtime=option('--runtime');
if(!runtime||!option('--out')||fs.existsSync(out))throw Error('Specify --runtime and a new --out directory.');
const saved=JSON.parse(fs.readFileSync(runtime,'utf8').replace(/^\uFEFF/,''));
assert.equal(saved.saspyCfgname,'winlocal');fs.mkdirSync(out,{recursive:true});
const relay=path.resolve(option('--relay')||path.join(__dirname,'../integrations/vscode/src/relay.js'));
const configFile=path.join(out,'runtime.json'),checks=[],records=[];let child,id=0,stderr='',port;
const pending=new Map(),session='windows_iom_validation',body=r=>(r.content||[]).map(c=>c.text||'').join('\n');
function start(){child=cp.spawn(process.execPath,[relay,'--config',configFile],{windowsHide:true,env:{...process.env,ELECTRON_RUN_AS_NODE:'1'}});
 child.stderr.on('data',b=>stderr+=b);child.on('error',e=>{for(const p of pending.values())p.reject(e);});
 child.on('exit',code=>{for(const p of pending.values())p.reject(Error('relay exited '+code));});
 rl.createInterface({input:child.stdout}).on('line',line=>{const r=JSON.parse(line),p=pending.get(r.id);records.push({received:r});if(p){clearTimeout(p.timer);pending.delete(r.id);r.error?p.reject(Error(r.error.message)):p.resolve(r.result);}});
}
function request(method,params={}){const q={jsonrpc:'2.0',id:++id,method,params};records.push({sent:q});return new Promise((resolve,reject)=>{const timer=setTimeout(()=>{pending.delete(q.id);reject(Error('MCP timeout'));},240000);pending.set(q.id,{resolve,reject,timer});child.stdin.write(JSON.stringify(q)+'\n');});}
async function close(){const ended=new Promise(resolve=>child.once('exit',resolve));child.stdin.end();assert.equal(await ended,0);}
async function submit(label,code,{expected='COMPLETE',sid=session,extra={}}={}){
 let result=await request('tools/call',{name:'run_sas_codes_or_files_in_ODA',arguments:{sas_codes_or_file:code,persistent:'true',session_id:sid,wait_seconds:20,max_log_chars:0,...extra}});
 const pid=body(result).match(/^PID:\s*(\d+)/m)?.[1];
 while(!/^STATUS: (COMPLETE|FAILED)/m.test(body(result))){assert.ok(pid);await new Promise(r=>setTimeout(r,1000));result=await request('tools/call',{name:'run_sas_codes_or_files_in_ODA',arguments:{pid:Number(pid),wait_seconds:20,max_log_chars:0}});}
 const text=body(result);fs.writeFileSync(path.join(out,label+'.txt'),text);assert.match(text,new RegExp('^STATUS: '+expected,'m'));
 if(expected==='COMPLETE')assert.ok(!/^\s*ERROR(?:\s+\d+-\d+)?:/m.test(text),text);
 checks.push({name:label,status:'PASS'});console.log('PASS: '+label);return text;
}
async function execute(){
 port=await core.allocateSessionPort();fs.writeFileSync(configFile,'\uFEFF'+JSON.stringify({...saved,sessionPort:port,cwd:out}));start();
 await request('initialize',{protocolVersion:'2024-11-05',capabilities:{},clientInfo:{name:'windows-iom-validation',version:'1'}});
 const tools=await request('tools/list');assert.equal(tools.tools.length,2);assert.ok(tools.tools.every(t=>!t.name.includes('local')));assert.equal(tools.tools[0].inputSchema.properties.saspy_cfgname.default,'winlocal');checks.push({name:'real MCP initialization, BOM config and SASPy-only discovery',status:'PASS'});
 await request('tools/call',{name:'run_sas_codes_or_files_in_ODA',arguments:{check_saspy_connection_only:'true',persistent:'false',wait_seconds:20}}).then(async result=>{
   while(!/^STATUS: (COMPLETE|FAILED)/m.test(body(result))){const pid=body(result).match(/^PID:\s*(\d+)/m)[1];result=await request('tools/call',{name:'run_sas_codes_or_files_in_ODA',arguments:{pid:Number(pid),wait_seconds:20}});}
   assert.match(body(result),/validation succeeded/);checks.push({name:'connection-only probe',status:'PASS'});
 });
 await submit('create-state',"data work.iom_saved;set sashelp.class;run; %let iom_marker=42; %macro iom_saved_macro; %put IOM_MACRO_OK &iom_marker; %mend; libname iomtest \"%sysfunc(pathname(work))\"; options nofmterr; %put IOM_PID &sysprocessid;");
 const verify="data _null_;if 0 then set work.iom_saved nobs=n; if n ne 19 then abort cancel;put 'IOM_WORK_OK n=' n;run; %iom_saved_macro; %put IOM_LIB_OK %sysfunc(libref(iomtest)); %put IOM_OPTION_OK %sysfunc(getoption(fmterr)); %put IOM_PID &sysprocessid;";
 let text=await submit('retained-work-macro-variable-libref-option',verify);assert.match(text,/^IOM_WORK_OK n=19\s*$/m);assert.match(text,/^IOM_MACRO_OK 42\s*$/m);assert.match(text,/^IOM_LIB_OK 0\s*$/m);assert.match(text,/^IOM_OPTION_OK NOFMTERR\s*$/m);
 await submit('independent-session',"%put IOM_OTHER_EXISTS %sysfunc(exist(work.iom_saved));",{sid:'windows_iom_other'}).then(t=>assert.match(t,/^IOM_OTHER_EXISTS 0\s*$/m));
 await submit('intentional-SAS-error','proc sql;select definitely_missing from work.iom_saved;quit;',{expected:'FAILED'});
 await submit('same-session-error-recovery',verify);
 await submit('background-submit','data _null_;rc=sleep(3,1);run;'+verify,{extra:{wait_seconds:0}});
 await close();start();await request('initialize',{});text=await submit('state-after-relay-restart',verify);assert.match(text,/^IOM_MACRO_OK 42\s*$/m);
 const macros=option('--macros');
 if(macros){
   const directory=path.resolve(macros),original=path.join(directory,'macroparas.sas'),bytes=fs.readFileSync(original);
   const quote=s=>s.replace(/\\/g,'/').replace(/"/g,'""');
   const names=['FileOrDirExist','del_file_with_fullpath','list_files','list_files4dsd','macroparas'];
   const includes=names.map(n=>`%include "${quote(path.join(directory,n+'.sas'))}";`).join('\n');
   text=await submit('original-macroparas-html',includes+`\n%macroparas(macrorgx=QueryGTEx4GeneID,dir=${quote(directory)},numlines2print=10000,output_macropara_dsd=iom_macro_paras,print_outdsd=0);\n%put ORIGINAL_MACROPARAS_OK;`);
   assert.match(text,/^ORIGINAL_MACROPARAS_OK\s*$/m);assert.deepEqual(fs.readFileSync(original),bytes);
   const htmlPath=text.match(/HTML output saved to:\s*(.+)/)?.[1]?.trim();assert.ok(htmlPath,'HTML artifact must exist');
   const nativePath=await core.run(path.join(path.dirname(saved.perl),'cygpath.exe'),['-w',htmlPath]);
   const html=fs.readFileSync(nativePath,'utf8');fs.copyFileSync(nativePath,path.join(out,'original-macroparas.html'));
   assert.match(html,/Contents of first 10000 lines of SAS macro/);assert.match(html,/darkblue|#00008B/i);assert.match(html,/edf2f9/i);assert.match(html,/geneids=Apobec3a Apobec3b/);assert.match(html,/proc http/);
   const decode=s=>s.replace(/<[^>]+>/g,'').replace(/&#(\d+);/g,(_,n)=>String.fromCodePoint(Number(n))).replace(/&#x([\da-f]+);/gi,(_,n)=>String.fromCodePoint(parseInt(n,16))).replace(/&(?:lt|gt|quot|apos|nbsp|amp);/g,m=>({'&lt;':'<','&gt;':'>','&quot;':'"','&apos;':"'",'&nbsp;':' ','&amp;':'&'}[m]));
   const copied=[...html.matchAll(/<td\b[^>]*class="data"[^>]*>([\s\S]*?)<\/td>/gi)].map(m=>decode(m[1]).trim()).join('\n');
   const expected=fs.readFileSync(path.join(directory,'QueryGTEx4GeneID.sas'),'utf8');
   assert.equal(copied.replace(/\s+/g,''),expected.replace(/\s+/g,''),'all source text survives copying from the HTML');
   fs.writeFileSync(path.join(out,'copied-from-html.sas'),copied);
   const compiled=await submit('compile-source-copied-from-original-html',copied+'\n%put IOM_COPIED_MACRO %sysmacexist(QueryGTEx4GeneID);',{sid:'windows_iom_html_copy'});
   assert.match(compiled,/^IOM_COPIED_MACRO 1\s*$/m);
   checks.push({name:'original macro source unchanged; full source and original HTML styles retained',status:'PASS'});
 }
 await close();
}
execute().then(()=>{fs.writeFileSync(path.join(out,'result.json'),JSON.stringify({complete:true,checks,scope:'real Windows SAS IOM via MCP relay; original macros only inspected, no GTEx HTTP requests'},null,2));}).catch(e=>{fs.writeFileSync(path.join(out,'result.json'),JSON.stringify({complete:false,checks,error:e.stack},null,2));console.error(e);process.exitCode=1;}).finally(async()=>{
 for(const p of pending.values())clearTimeout(p.timer);if(child&&child.exitCode===null)child.kill();
 fs.writeFileSync(path.join(out,'mcp-records.json'),JSON.stringify(records,null,2));fs.writeFileSync(path.join(out,'relay-stderr.txt'),stderr);
 // The allocated port belongs only to this test, never the user's sessions.
 if(port)try{await core.run(saved.python,['-c',`import socket,json\ns=socket.create_connection(('127.0.0.1',${port}),timeout=5)\nb=json.dumps({'cmd':'shutdown'}).encode();s.sendall(len(b).to_bytes(8,'big')+b);s.close()`],{timeout:10000});}catch{}
});
