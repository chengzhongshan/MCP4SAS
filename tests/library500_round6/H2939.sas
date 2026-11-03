/* H2939 symlocal_symglobl_scope, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let h2939value=10;
%macro h2939m(); %local h2939value; %let h2939value=11;
data h2939a; actual=&h2939value+%symlocal(h2939value)+%symglobl(h2939value); run;
%mend; %h2939m();
data h2939o; set h2939a; actual=actual+&h2939value; run;
%symdel h2939value; %sysmacdelete h2939m;

data _null_; if 0 then set h2939o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2939 rows=' rows;
else do; set h2939o; if not missing(actual) and abs(actual-(23))<=1e-9*max(1,abs(23)) then put 'ROUND6_PASS=H2939';
else put 'ERROR: ROUND6_FAIL=H2939 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2939:; quit;
