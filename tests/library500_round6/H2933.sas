/* H2933 symlocal_symglobl_scope, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let h2933value=4;
%macro h2933m(); %local h2933value; %let h2933value=5;
data h2933a; actual=&h2933value+%symlocal(h2933value)+%symglobl(h2933value); run;
%mend; %h2933m();
data h2933o; set h2933a; actual=actual+&h2933value; run;
%symdel h2933value; %sysmacdelete h2933m;

data _null_; if 0 then set h2933o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2933 rows=' rows;
else do; set h2933o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2933';
else put 'ERROR: ROUND6_FAIL=H2933 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2933:; quit;
