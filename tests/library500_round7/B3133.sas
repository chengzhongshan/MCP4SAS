/* B3133 set_in_origin_flags, N=4; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3133a; do x=1 to 4; output; end; run;
data b3133b; do x=1 to 5; output; end; run;
data b3133c; set b3133a(in=ina) b3133b(in=inb); value=ina+10*inb; run;
proc sql; create table b3133o as select sum(value) as actual from b3133c; quit;

data _null_; if 0 then set b3133o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3133 rows=' rows;
else do; set b3133o; if not missing(actual) and abs(actual-(54))<=1e-9*max(1,abs(54)) then put 'ROUND7_PASS=B3133';
else put 'ERROR: ROUND7_FAIL=B3133 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3133:; quit;
