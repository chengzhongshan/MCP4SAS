/* B3076 multi_output_partition, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3076a b3076b; do x=-7 to 7; if x<0 then output b3076a; else if x>0 then output b3076b; end; run;
proc sql; create table b3076c as select sum(x) as negative from b3076a;
create table b3076d as select sum(x) as positive from b3076b;
create table b3076o as select positive-negative as actual from b3076c,b3076d; quit;

data _null_; if 0 then set b3076o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3076 rows=' rows;
else do; set b3076o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND7_PASS=B3076';
else put 'ERROR: ROUND7_FAIL=B3076 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3076:; quit;
