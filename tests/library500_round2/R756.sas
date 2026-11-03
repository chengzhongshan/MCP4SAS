/* R756 nobs_metadata, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:34 */

data r756a; do x=1 to 7; output; end; run;
data r756o; if 0 then set r756a nobs=number; actual=number; output; stop; run;

data _null_; if 0 then set r756o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R756 rows=' rows;
else do; set r756o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R756';
else put 'ERROR: ROUND2_FAIL=R756 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r756:; quit;
