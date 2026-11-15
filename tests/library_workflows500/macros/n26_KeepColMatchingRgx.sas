/* Test-only namespaced definition from KeepColMatchingRgx.sas; original SHA256 465d09606a40e2434290cb31201964941d611c71a803f5f97113d13c26d457f0. */
%macro n26_KeepColMatchingRgx(indsd,Rgx,outdsd,insensitive);
%let dsd_name=%scan(&indsd,-1,'.');
%let dsd_lib=%scan(&indsd,-2,'.');
%if (&insensitive eq 1) %then %do;
 %put Rgx will be case insensitive;
 %let Rgexp=/&rgx/i;
%end;
%else %do;
 %let insensitive=0;
 %put Rgx will be case sensitive;
 %let Rgexp=/&rgx/;
%end;
proc sql noprint;
create table temp as 
select name,label,format
  from dictionary.columns
  where libname=upper("&dsd_lib") and
        memname=upper("&dsd_name") and 
		memtype="DATA";
data temp;
set temp;
if prxmatch("&Rgexp",name);
run;

proc sql noprint;
   select name into :kept_vars separated by ' '
      from temp;
quit;

data &outdsd;
set &indsd;
keep &kept_vars;
run;

%mend;
