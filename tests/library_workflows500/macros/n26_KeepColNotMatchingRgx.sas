/* Test-only namespaced definition from KeepColNotMatchingRgx.sas; original SHA256 d6adc3fdeba33c7760db29d6c582efa8dab247e69967b49faf3bc875a3db787e. */
%macro n26_KeepColNotMatchingRgx(indsd,Rgx,outdsd);
%let dsd_name=%scan(&indsd,-1,'.');
%let dsd_lib=%scan(&indsd,-2,'.');
proc sql noprint;
create table temp as 
select name,label,format
  from dictionary.columns
  where libname=upper("&dsd_lib") and
        memname=upper("&dsd_name") and 
		memtype="DATA";
data temp(where=(g=1));
set temp;
g=1;
if prxmatch("/&Rgx/",name) then g=0;
run;

proc sql noprint;
      select name into: kept_vars separated by ' '
      from temp;

data &outdsd;
set &indsd;
keep &kept_vars;
run;

%mend;
