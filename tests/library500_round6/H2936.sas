/* H2936 symlocal_symglobl_scope, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let h2936value=7;
%macro h2936m(); %local h2936value; %let h2936value=8;
data h2936a; actual=&h2936value+%symlocal(h2936value)+%symglobl(h2936value); run;
%mend; %h2936m();
data h2936o; set h2936a; actual=actual+&h2936value; run;
%symdel h2936value; %sysmacdelete h2936m;

data _null_; if 0 then set h2936o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2936 rows=' rows;
else do; set h2936o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND6_PASS=H2936';
else put 'ERROR: ROUND6_FAIL=H2936 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2936:; quit;
