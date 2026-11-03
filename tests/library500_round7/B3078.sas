/* B3078 multi_output_partition, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3078a b3078b; do x=-9 to 9; if x<0 then output b3078a; else if x>0 then output b3078b; end; run;
proc sql; create table b3078c as select sum(x) as negative from b3078a;
create table b3078d as select sum(x) as positive from b3078b;
create table b3078o as select positive-negative as actual from b3078c,b3078d; quit;

data _null_; if 0 then set b3078o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3078 rows=' rows;
else do; set b3078o; if not missing(actual) and abs(actual-(90))<=1e-9*max(1,abs(90)) then put 'ROUND7_PASS=B3078';
else put 'ERROR: ROUND7_FAIL=B3078 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3078:; quit;
