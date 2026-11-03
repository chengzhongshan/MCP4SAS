/* B3137 set_in_origin_flags, N=8; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3137a; do x=1 to 8; output; end; run;
data b3137b; do x=1 to 9; output; end; run;
data b3137c; set b3137a(in=ina) b3137b(in=inb); value=ina+10*inb; run;
proc sql; create table b3137o as select sum(value) as actual from b3137c; quit;

data _null_; if 0 then set b3137o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3137 rows=' rows;
else do; set b3137o; if not missing(actual) and abs(actual-(98))<=1e-9*max(1,abs(98)) then put 'ROUND7_PASS=B3137';
else put 'ERROR: ROUND7_FAIL=B3137 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3137:; quit;
