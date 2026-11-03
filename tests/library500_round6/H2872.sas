/* H2872 fcopy_owned_temp, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:140 */

filename srcfile temp; filename dstfile temp;
data _null_; file srcfile; put '3'; run;
data _null_; rc=fcopy('srcfile','dstfile'); if rc ne 0 then put 'ERROR: FCOPY fixture failed'; run;
data h2872o; infile dstfile; input actual; run;
filename srcfile clear; filename dstfile clear;

data _null_; if 0 then set h2872o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2872 rows=' rows;
else do; set h2872o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2872';
else put 'ERROR: ROUND6_FAIL=H2872 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2872:; quit;
