/* R753 nobs_metadata, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:34 */

data r753a; do x=1 to 4; output; end; run;
data r753o; if 0 then set r753a nobs=number; actual=number; output; stop; run;

data _null_; if 0 then set r753o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R753 rows=' rows;
else do; set r753o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R753';
else put 'ERROR: ROUND2_FAIL=R753 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r753:; quit;
