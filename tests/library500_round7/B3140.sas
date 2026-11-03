/* B3140 set_in_origin_flags, N=11; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3140a; do x=1 to 11; output; end; run;
data b3140b; do x=1 to 12; output; end; run;
data b3140c; set b3140a(in=ina) b3140b(in=inb); value=ina+10*inb; run;
proc sql; create table b3140o as select sum(value) as actual from b3140c; quit;

data _null_; if 0 then set b3140o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3140 rows=' rows;
else do; set b3140o; if not missing(actual) and abs(actual-(131))<=1e-9*max(1,abs(131)) then put 'ROUND7_PASS=B3140';
else put 'ERROR: ROUND7_FAIL=B3140 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3140:; quit;
