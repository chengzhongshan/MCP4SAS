/* K4290 expression_log2_checksum, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:209 */

data k4290a; do sample=1 to 11; tpm=2**sample-1; logged=log2(tpm+1); output; end; run;
proc sql; create table k4290o as select sum(logged) as actual from k4290a; quit;

data _null_; if 0 then set k4290o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4290 rows=' rows;
else do; set k4290o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND10_PASS=K4290';
else put 'ERROR: ROUND10_FAIL=K4290 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4290:; quit;
