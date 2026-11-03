/* B3131 set_in_origin_flags, N=2; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3131a; do x=1 to 2; output; end; run;
data b3131b; do x=1 to 3; output; end; run;
data b3131c; set b3131a(in=ina) b3131b(in=inb); value=ina+10*inb; run;
proc sql; create table b3131o as select sum(value) as actual from b3131c; quit;

data _null_; if 0 then set b3131o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3131 rows=' rows;
else do; set b3131o; if not missing(actual) and abs(actual-(32))<=1e-9*max(1,abs(32)) then put 'ROUND7_PASS=B3131';
else put 'ERROR: ROUND7_FAIL=B3131 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3131:; quit;
