/* B3138 set_in_origin_flags, N=9; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3138a; do x=1 to 9; output; end; run;
data b3138b; do x=1 to 10; output; end; run;
data b3138c; set b3138a(in=ina) b3138b(in=inb); value=ina+10*inb; run;
proc sql; create table b3138o as select sum(value) as actual from b3138c; quit;

data _null_; if 0 then set b3138o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3138 rows=' rows;
else do; set b3138o; if not missing(actual) and abs(actual-(109))<=1e-9*max(1,abs(109)) then put 'ROUND7_PASS=B3138';
else put 'ERROR: ROUND7_FAIL=B3138 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3138:; quit;
