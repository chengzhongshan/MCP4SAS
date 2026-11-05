/* K4287 expression_log2_checksum, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:209 */

data k4287a; do sample=1 to 8; tpm=2**sample-1; logged=log2(tpm+1); output; end; run;
proc sql; create table k4287o as select sum(logged) as actual from k4287a; quit;

data _null_; if 0 then set k4287o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4287 rows=' rows;
else do; set k4287o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND10_PASS=K4287';
else put 'ERROR: ROUND10_FAIL=K4287 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4287:; quit;
