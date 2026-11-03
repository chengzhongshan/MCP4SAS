/* H2879 fcopy_owned_temp, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:140 */

filename srcfile temp; filename dstfile temp;
data _null_; file srcfile; put '10'; run;
data _null_; rc=fcopy('srcfile','dstfile'); if rc ne 0 then put 'ERROR: FCOPY fixture failed'; run;
data h2879o; infile dstfile; input actual; run;
filename srcfile clear; filename dstfile clear;

data _null_; if 0 then set h2879o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2879 rows=' rows;
else do; set h2879o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2879';
else put 'ERROR: ROUND6_FAIL=H2879 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2879:; quit;
