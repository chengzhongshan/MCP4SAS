/* H2932 symlocal_symglobl_scope, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let h2932value=3;
%macro h2932m(); %local h2932value; %let h2932value=4;
data h2932a; actual=&h2932value+%symlocal(h2932value)+%symglobl(h2932value); run;
%mend; %h2932m();
data h2932o; set h2932a; actual=actual+&h2932value; run;
%symdel h2932value; %sysmacdelete h2932m;

data _null_; if 0 then set h2932o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2932 rows=' rows;
else do; set h2932o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2932';
else put 'ERROR: ROUND6_FAIL=H2932 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2932:; quit;
