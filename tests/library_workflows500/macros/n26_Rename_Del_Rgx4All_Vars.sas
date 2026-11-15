/* Test-only namespaced definition from Rename_Del_Rgx4All_Vars.sas; original SHA256 59d54076618f9612ae838c8acb445b0dbf17f12d6f891614ff6bcc6ed28435ba. */
%macro n26_Rename_Del_Rgx4All_Vars(indsd,Rgx);
%let dsd_name=%scan(&indsd,-1,'.');
%let dsd_lib=%scan(&indsd,-2,'.');
proc sql noprint;
create table temp as 
select name,label,format
  from dictionary.columns
  where libname=upper("&dsd_lib") and
        memname=upper("&dsd_name") and 
		memtype="DATA";
data temp;
set temp;
newname=prxchange("s/&Rgx//",-1,name);
run;

proc sql noprint;
   select count(*) into :n from temp
   where prxmatch("/&Rgx/",name);

%if &n>0 %then %do;
proc sql noprint;
   select cat('rename ',strip(name),
              '= ',strip(newname),';')
      into :l1 - %sysfunc(compress(:l&n))
      from temp
   where prxmatch("/&Rgx/",name);
quit;

proc datasets lib=&dsd_lib nolist;
modify &dsd_name;
   %do i = 1 %to &n; 
     &&l&i 
   %end;
run;
%end;

%mend;
