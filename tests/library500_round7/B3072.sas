/* B3072 multi_output_partition, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3072a b3072b; do x=-3 to 3; if x<0 then output b3072a; else if x>0 then output b3072b; end; run;
proc sql; create table b3072c as select sum(x) as negative from b3072a;
create table b3072d as select sum(x) as positive from b3072b;
create table b3072o as select positive-negative as actual from b3072c,b3072d; quit;

data _null_; if 0 then set b3072o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3072 rows=' rows;
else do; set b3072o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3072';
else put 'ERROR: ROUND7_FAIL=B3072 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3072:; quit;
