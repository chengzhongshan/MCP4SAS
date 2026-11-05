/* K4281 expression_log2_checksum, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:209 */

data k4281a; do sample=1 to 2; tpm=2**sample-1; logged=log2(tpm+1); output; end; run;
proc sql; create table k4281o as select sum(logged) as actual from k4281a; quit;

data _null_; if 0 then set k4281o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4281 rows=' rows;
else do; set k4281o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4281';
else put 'ERROR: ROUND10_FAIL=K4281 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4281:; quit;
