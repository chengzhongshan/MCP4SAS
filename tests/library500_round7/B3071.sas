/* B3071 multi_output_partition, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3071a b3071b; do x=-2 to 2; if x<0 then output b3071a; else if x>0 then output b3071b; end; run;
proc sql; create table b3071c as select sum(x) as negative from b3071a;
create table b3071d as select sum(x) as positive from b3071b;
create table b3071o as select positive-negative as actual from b3071c,b3071d; quit;

data _null_; if 0 then set b3071o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3071 rows=' rows;
else do; set b3071o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3071';
else put 'ERROR: ROUND7_FAIL=B3071 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3071:; quit;
