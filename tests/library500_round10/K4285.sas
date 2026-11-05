/* K4285 expression_log2_checksum, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:209 */

data k4285a; do sample=1 to 6; tpm=2**sample-1; logged=log2(tpm+1); output; end; run;
proc sql; create table k4285o as select sum(logged) as actual from k4285a; quit;

data _null_; if 0 then set k4285o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4285 rows=' rows;
else do; set k4285o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND10_PASS=K4285';
else put 'ERROR: ROUND10_FAIL=K4285 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4285:; quit;
