/* H2938 symlocal_symglobl_scope, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let h2938value=9;
%macro h2938m(); %local h2938value; %let h2938value=10;
data h2938a; actual=&h2938value+%symlocal(h2938value)+%symglobl(h2938value); run;
%mend; %h2938m();
data h2938o; set h2938a; actual=actual+&h2938value; run;
%symdel h2938value; %sysmacdelete h2938m;

data _null_; if 0 then set h2938o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2938 rows=' rows;
else do; set h2938o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND6_PASS=H2938';
else put 'ERROR: ROUND6_FAIL=H2938 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2938:; quit;
