/* H2931 symlocal_symglobl_scope, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let h2931value=2;
%macro h2931m(); %local h2931value; %let h2931value=3;
data h2931a; actual=&h2931value+%symlocal(h2931value)+%symglobl(h2931value); run;
%mend; %h2931m();
data h2931o; set h2931a; actual=actual+&h2931value; run;
%symdel h2931value; %sysmacdelete h2931m;

data _null_; if 0 then set h2931o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2931 rows=' rows;
else do; set h2931o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2931';
else put 'ERROR: ROUND6_FAIL=H2931 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2931:; quit;
