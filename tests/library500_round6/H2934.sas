/* H2934 symlocal_symglobl_scope, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/When infile too many missing data, need to use dsd with dlm and add m for scan.sas:66 */

%let h2934value=5;
%macro h2934m(); %local h2934value; %let h2934value=6;
data h2934a; actual=&h2934value+%symlocal(h2934value)+%symglobl(h2934value); run;
%mend; %h2934m();
data h2934o; set h2934a; actual=actual+&h2934value; run;
%symdel h2934value; %sysmacdelete h2934m;

data _null_; if 0 then set h2934o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2934 rows=' rows;
else do; set h2934o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND6_PASS=H2934';
else put 'ERROR: ROUND6_FAIL=H2934 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2934:; quit;
