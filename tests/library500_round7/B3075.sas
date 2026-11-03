/* B3075 multi_output_partition, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3075a b3075b; do x=-6 to 6; if x<0 then output b3075a; else if x>0 then output b3075b; end; run;
proc sql; create table b3075c as select sum(x) as negative from b3075a;
create table b3075d as select sum(x) as positive from b3075b;
create table b3075o as select positive-negative as actual from b3075c,b3075d; quit;

data _null_; if 0 then set b3075o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3075 rows=' rows;
else do; set b3075o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND7_PASS=B3075';
else put 'ERROR: ROUND7_FAIL=B3075 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3075:; quit;
