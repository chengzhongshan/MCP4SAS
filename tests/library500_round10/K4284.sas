/* K4284 expression_log2_checksum, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:209 */

data k4284a; do sample=1 to 5; tpm=2**sample-1; logged=log2(tpm+1); output; end; run;
proc sql; create table k4284o as select sum(logged) as actual from k4284a; quit;

data _null_; if 0 then set k4284o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4284 rows=' rows;
else do; set k4284o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND10_PASS=K4284';
else put 'ERROR: ROUND10_FAIL=K4284 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4284:; quit;
