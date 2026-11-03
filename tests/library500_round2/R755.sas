/* R755 nobs_metadata, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:34 */

data r755a; do x=1 to 6; output; end; run;
data r755o; if 0 then set r755a nobs=number; actual=number; output; stop; run;

data _null_; if 0 then set r755o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R755 rows=' rows;
else do; set r755o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R755';
else put 'ERROR: ROUND2_FAIL=R755 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r755:; quit;
