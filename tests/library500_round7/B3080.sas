/* B3080 multi_output_partition, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3080a b3080b; do x=-11 to 11; if x<0 then output b3080a; else if x>0 then output b3080b; end; run;
proc sql; create table b3080c as select sum(x) as negative from b3080a;
create table b3080d as select sum(x) as positive from b3080b;
create table b3080o as select positive-negative as actual from b3080c,b3080d; quit;

data _null_; if 0 then set b3080o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3080 rows=' rows;
else do; set b3080o; if not missing(actual) and abs(actual-(132))<=1e-9*max(1,abs(132)) then put 'ROUND7_PASS=B3080';
else put 'ERROR: ROUND7_FAIL=B3080 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3080:; quit;
