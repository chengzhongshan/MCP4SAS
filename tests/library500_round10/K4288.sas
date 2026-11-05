/* K4288 expression_log2_checksum, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:209 */

data k4288a; do sample=1 to 9; tpm=2**sample-1; logged=log2(tpm+1); output; end; run;
proc sql; create table k4288o as select sum(logged) as actual from k4288a; quit;

data _null_; if 0 then set k4288o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4288 rows=' rows;
else do; set k4288o; if not missing(actual) and abs(actual-(45))<=1e-9*max(1,abs(45)) then put 'ROUND10_PASS=K4288';
else put 'ERROR: ROUND10_FAIL=K4288 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4288:; quit;
