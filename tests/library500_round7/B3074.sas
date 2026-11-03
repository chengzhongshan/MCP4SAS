/* B3074 multi_output_partition, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3074a b3074b; do x=-5 to 5; if x<0 then output b3074a; else if x>0 then output b3074b; end; run;
proc sql; create table b3074c as select sum(x) as negative from b3074a;
create table b3074d as select sum(x) as positive from b3074b;
create table b3074o as select positive-negative as actual from b3074c,b3074d; quit;

data _null_; if 0 then set b3074o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3074 rows=' rows;
else do; set b3074o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND7_PASS=B3074';
else put 'ERROR: ROUND7_FAIL=B3074 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3074:; quit;
