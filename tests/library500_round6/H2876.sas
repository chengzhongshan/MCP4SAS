/* H2876 fcopy_owned_temp, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:140 */

filename srcfile temp; filename dstfile temp;
data _null_; file srcfile; put '7'; run;
data _null_; rc=fcopy('srcfile','dstfile'); if rc ne 0 then put 'ERROR: FCOPY fixture failed'; run;
data h2876o; infile dstfile; input actual; run;
filename srcfile clear; filename dstfile clear;

data _null_; if 0 then set h2876o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2876 rows=' rows;
else do; set h2876o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2876';
else put 'ERROR: ROUND6_FAIL=H2876 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2876:; quit;
