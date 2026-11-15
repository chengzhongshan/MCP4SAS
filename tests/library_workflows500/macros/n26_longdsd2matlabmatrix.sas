/* Test-only namespaced definition from longdsd2matlabmatrix.sas; original SHA256 b2519789067e10abf900692bc291d5f2d7c65879cef3e83e888e4f6cb0fc8f62. */
%macro n26_longdsd2matlabmatrix(dsd,var_row,var_col,data_var,value2asign4missing,dsdout,outdir4matrix);
proc sort data=&dsd;by &var_row &var_col;
proc transpose data=&dsd out=&dsdout(drop=_name_);
var &data_var;
by &var_row;
id &var_col;
run;

data &dsdout;
set &dsdout;
array x{*} _numeric_;
do i=1 to dim(x);
 if x{i}=. then x{i}=&value2asign4missing;
end;
drop i;
run;

%if %eval(&outdir4matrix^=) %then %do;
proc export data=&dsdout(keep=&var_row) outfile="&outdir4matrix/rowlabels.txt" replace
dbms=tab;putnames=no;
run;
proc export data=&dsdout(drop=&var_row) outfile="&outdir4matrix/matrix.tab" replace
dbms=tab;putnames=no;
run;
proc export data=&dsdout(drop=&var_row obs=0) outfile="&outdir4matrix/collabels.txt" replace
dbms=tab;putnames=yes;
run;
%end;


%mend;
