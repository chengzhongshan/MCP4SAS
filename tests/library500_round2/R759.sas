/* R759 nobs_metadata, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:34 */

data r759a; do x=1 to 10; output; end; run;
data r759o; if 0 then set r759a nobs=number; actual=number; output; stop; run;

data _null_; if 0 then set r759o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R759 rows=' rows;
else do; set r759o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R759';
else put 'ERROR: ROUND2_FAIL=R759 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r759:; quit;
