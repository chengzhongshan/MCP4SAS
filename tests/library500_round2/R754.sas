/* R754 nobs_metadata, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:34 */

data r754a; do x=1 to 5; output; end; run;
data r754o; if 0 then set r754a nobs=number; actual=number; output; stop; run;

data _null_; if 0 then set r754o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R754 rows=' rows;
else do; set r754o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R754';
else put 'ERROR: ROUND2_FAIL=R754 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r754:; quit;
