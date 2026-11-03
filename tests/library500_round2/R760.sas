/* R760 nobs_metadata, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:34 */

data r760a; do x=1 to 11; output; end; run;
data r760o; if 0 then set r760a nobs=number; actual=number; output; stop; run;

data _null_; if 0 then set r760o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R760 rows=' rows;
else do; set r760o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND2_PASS=R760';
else put 'ERROR: ROUND2_FAIL=R760 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r760:; quit;
