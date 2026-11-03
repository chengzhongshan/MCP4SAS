/* H2940 symlocal_symglobl_scope, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let h2940value=11;
%macro h2940m(); %local h2940value; %let h2940value=12;
data h2940a; actual=&h2940value+%symlocal(h2940value)+%symglobl(h2940value); run;
%mend; %h2940m();
data h2940o; set h2940a; actual=actual+&h2940value; run;
%symdel h2940value; %sysmacdelete h2940m;

data _null_; if 0 then set h2940o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2940 rows=' rows;
else do; set h2940o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND6_PASS=H2940';
else put 'ERROR: ROUND6_FAIL=H2940 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2940:; quit;
