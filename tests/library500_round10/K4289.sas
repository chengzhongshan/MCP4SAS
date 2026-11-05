/* K4289 expression_log2_checksum, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:209 */

data k4289a; do sample=1 to 10; tpm=2**sample-1; logged=log2(tpm+1); output; end; run;
proc sql; create table k4289o as select sum(logged) as actual from k4289a; quit;

data _null_; if 0 then set k4289o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4289 rows=' rows;
else do; set k4289o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND10_PASS=K4289';
else put 'ERROR: ROUND10_FAIL=K4289 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4289:; quit;
