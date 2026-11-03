/* H2937 symlocal_symglobl_scope, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let h2937value=8;
%macro h2937m(); %local h2937value; %let h2937value=9;
data h2937a; actual=&h2937value+%symlocal(h2937value)+%symglobl(h2937value); run;
%mend; %h2937m();
data h2937o; set h2937a; actual=actual+&h2937value; run;
%symdel h2937value; %sysmacdelete h2937m;

data _null_; if 0 then set h2937o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2937 rows=' rows;
else do; set h2937o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND6_PASS=H2937';
else put 'ERROR: ROUND6_FAIL=H2937 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2937:; quit;
