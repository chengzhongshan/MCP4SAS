/* R757 nobs_metadata, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:34 */

data r757a; do x=1 to 8; output; end; run;
data r757o; if 0 then set r757a nobs=number; actual=number; output; stop; run;

data _null_; if 0 then set r757o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R757 rows=' rows;
else do; set r757o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND2_PASS=R757';
else put 'ERROR: ROUND2_FAIL=R757 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r757:; quit;
