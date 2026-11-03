/* B3077 multi_output_partition, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3077a b3077b; do x=-8 to 8; if x<0 then output b3077a; else if x>0 then output b3077b; end; run;
proc sql; create table b3077c as select sum(x) as negative from b3077a;
create table b3077d as select sum(x) as positive from b3077b;
create table b3077o as select positive-negative as actual from b3077c,b3077d; quit;

data _null_; if 0 then set b3077o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3077 rows=' rows;
else do; set b3077o; if not missing(actual) and abs(actual-(72))<=1e-9*max(1,abs(72)) then put 'ROUND7_PASS=B3077';
else put 'ERROR: ROUND7_FAIL=B3077 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3077:; quit;
