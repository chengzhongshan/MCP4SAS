/* Test-only namespaced definition from get_num_or_char_vars4dsd.sas; original SHA256 d7f654395881375ee0e13c9be258ef6656cec85b59f9d9186103358ab9ac8533. */
%macro n26_get_num_or_char_vars4dsd(indsd,outdsd,numeric);
%if &numeric=0 %then %do;
  %let var_type=char;
%end;
%else %do;
  %let var_type=num;
%end;

%let dsd_name=%scan(&indsd,-1,'.');
%let dsd_lib=%scan(&indsd,-2,'.');
/*In case of no libname was provided*/
%if %eval(&dsd_lib=) %then %let dsd_lib=work;
proc sql;
create table &outdsd as 
select name,label,format,type
  from dictionary.columns
  where libname=upper("&dsd_lib") and
        memname=upper("&dsd_name") and 
		memtype="DATA" and 
        type="&var_type";
quit;
%mend;
