/* B3073 multi_output_partition, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3073a b3073b; do x=-4 to 4; if x<0 then output b3073a; else if x>0 then output b3073b; end; run;
proc sql; create table b3073c as select sum(x) as negative from b3073a;
create table b3073d as select sum(x) as positive from b3073b;
create table b3073o as select positive-negative as actual from b3073c,b3073d; quit;

data _null_; if 0 then set b3073o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3073 rows=' rows;
else do; set b3073o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND7_PASS=B3073';
else put 'ERROR: ROUND7_FAIL=B3073 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3073:; quit;
