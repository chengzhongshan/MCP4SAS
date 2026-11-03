/* B3132 set_in_origin_flags, N=3; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3132a; do x=1 to 3; output; end; run;
data b3132b; do x=1 to 4; output; end; run;
data b3132c; set b3132a(in=ina) b3132b(in=inb); value=ina+10*inb; run;
proc sql; create table b3132o as select sum(value) as actual from b3132c; quit;

data _null_; if 0 then set b3132o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3132 rows=' rows;
else do; set b3132o; if not missing(actual) and abs(actual-(43))<=1e-9*max(1,abs(43)) then put 'ROUND7_PASS=B3132';
else put 'ERROR: ROUND7_FAIL=B3132 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3132:; quit;
