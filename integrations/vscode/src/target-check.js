'use strict';
const CODE='proc print data=sashelp.class(obs=5);run;proc means data=sashelp.class noprint;var Age;output out=work.mcp4sas_target_check n=n nmiss=missing min=minimum max=maximum;run;data _null_;set work.mcp4sas_target_check;put "MCP4SAS_TARGET_CHECK " n= missing= minimum= maximum=;put "MCP4SAS_PLATFORM &sysscp &sysvlong";run;%put MCP4SAS_WORK=%sysfunc(pathname(work));';
function verify(log, profile='oda') {
  if(!/^MCP4SAS_TARGET_CHECK n=19 missing=0 minimum=11 maximum=16\s*$/m.test(log)||/^\s*ERROR(?:\s+\d+-\d+)?:/m.test(log))throw Error('SAS check did not return the expected observed values.');
  const platform=log.match(/^MCP4SAS_PLATFORM ([^\r\n]+)/m)?.[1];
  const work=log.match(/^MCP4SAS_WORK=([^\r\n]+)/m)?.[1]?.trim();
  if(!platform||!work)throw Error('SAS check did not report its execution platform and WORK directory.');
  const odaHost=/\.oda\.sas\.com(?:[\\/]|$)/i.test(work);
  if(profile==='oda'&&(!/^LIN\b/.test(platform)||!odaHost))throw Error('Selected SAS ODA, but the returned platform/WORK directory does not identify the ODA server.');
  if(/^winlocal(?:_com)?$/.test(profile)&&(!/^WIN\b/.test(platform)||odaHost))throw Error('Selected local Windows SAS, but the returned platform/WORK directory identifies a different SAS host.');
  if(/^(linuxlocal|local|stdio)$/.test(profile)&&(!/^LIN\b/.test(platform)||odaHost))throw Error('Selected local Linux SAS, but the returned platform/WORK directory identifies a different SAS host.');
  return {platform,work};
}
module.exports={CODE,verify};
