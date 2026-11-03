/* H2935 symlocal_symglobl_scope, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let h2935value=6;
%macro h2935m(); %local h2935value; %let h2935value=7;
data h2935a; actual=&h2935value+%symlocal(h2935value)+%symglobl(h2935value); run;
%mend; %h2935m();
data h2935o; set h2935a; actual=actual+&h2935value; run;
%symdel h2935value; %sysmacdelete h2935m;

data _null_; if 0 then set h2935o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2935 rows=' rows;
else do; set h2935o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND6_PASS=H2935';
else put 'ERROR: ROUND6_FAIL=H2935 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2935:; quit;
