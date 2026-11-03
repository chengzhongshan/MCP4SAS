/* B3135 set_in_origin_flags, N=6; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3135a; do x=1 to 6; output; end; run;
data b3135b; do x=1 to 7; output; end; run;
data b3135c; set b3135a(in=ina) b3135b(in=inb); value=ina+10*inb; run;
proc sql; create table b3135o as select sum(value) as actual from b3135c; quit;

data _null_; if 0 then set b3135o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3135 rows=' rows;
else do; set b3135o; if not missing(actual) and abs(actual-(76))<=1e-9*max(1,abs(76)) then put 'ROUND7_PASS=B3135';
else put 'ERROR: ROUND7_FAIL=B3135 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3135:; quit;
