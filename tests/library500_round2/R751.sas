/* R751 nobs_metadata, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:34 */

data r751a; do x=1 to 2; output; end; run;
data r751o; if 0 then set r751a nobs=number; actual=number; output; stop; run;

data _null_; if 0 then set r751o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R751 rows=' rows;
else do; set r751o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND2_PASS=R751';
else put 'ERROR: ROUND2_FAIL=R751 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r751:; quit;
