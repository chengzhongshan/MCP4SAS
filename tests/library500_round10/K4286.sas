/* K4286 expression_log2_checksum, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:209 */

data k4286a; do sample=1 to 7; tpm=2**sample-1; logged=log2(tpm+1); output; end; run;
proc sql; create table k4286o as select sum(logged) as actual from k4286a; quit;

data _null_; if 0 then set k4286o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4286 rows=' rows;
else do; set k4286o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND10_PASS=K4286';
else put 'ERROR: ROUND10_FAIL=K4286 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4286:; quit;
