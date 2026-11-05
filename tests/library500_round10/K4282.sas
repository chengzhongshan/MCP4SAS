/* K4282 expression_log2_checksum, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:209 */

data k4282a; do sample=1 to 3; tpm=2**sample-1; logged=log2(tpm+1); output; end; run;
proc sql; create table k4282o as select sum(logged) as actual from k4282a; quit;

data _null_; if 0 then set k4282o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4282 rows=' rows;
else do; set k4282o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4282';
else put 'ERROR: ROUND10_FAIL=K4282 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4282:; quit;
