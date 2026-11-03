/* B3079 multi_output_partition, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3079a b3079b; do x=-10 to 10; if x<0 then output b3079a; else if x>0 then output b3079b; end; run;
proc sql; create table b3079c as select sum(x) as negative from b3079a;
create table b3079d as select sum(x) as positive from b3079b;
create table b3079o as select positive-negative as actual from b3079c,b3079d; quit;

data _null_; if 0 then set b3079o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3079 rows=' rows;
else do; set b3079o; if not missing(actual) and abs(actual-(110))<=1e-9*max(1,abs(110)) then put 'ROUND7_PASS=B3079';
else put 'ERROR: ROUND7_FAIL=B3079 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3079:; quit;
