/* B3136 set_in_origin_flags, N=7; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3136a; do x=1 to 7; output; end; run;
data b3136b; do x=1 to 8; output; end; run;
data b3136c; set b3136a(in=ina) b3136b(in=inb); value=ina+10*inb; run;
proc sql; create table b3136o as select sum(value) as actual from b3136c; quit;

data _null_; if 0 then set b3136o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3136 rows=' rows;
else do; set b3136o; if not missing(actual) and abs(actual-(87))<=1e-9*max(1,abs(87)) then put 'ROUND7_PASS=B3136';
else put 'ERROR: ROUND7_FAIL=B3136 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3136:; quit;
