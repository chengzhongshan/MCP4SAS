/* B3134 set_in_origin_flags, N=5; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3134a; do x=1 to 5; output; end; run;
data b3134b; do x=1 to 6; output; end; run;
data b3134c; set b3134a(in=ina) b3134b(in=inb); value=ina+10*inb; run;
proc sql; create table b3134o as select sum(value) as actual from b3134c; quit;

data _null_; if 0 then set b3134o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3134 rows=' rows;
else do; set b3134o; if not missing(actual) and abs(actual-(65))<=1e-9*max(1,abs(65)) then put 'ROUND7_PASS=B3134';
else put 'ERROR: ROUND7_FAIL=B3134 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3134:; quit;
