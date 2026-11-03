/* B3139 set_in_origin_flags, N=10; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3139a; do x=1 to 10; output; end; run;
data b3139b; do x=1 to 11; output; end; run;
data b3139c; set b3139a(in=ina) b3139b(in=inb); value=ina+10*inb; run;
proc sql; create table b3139o as select sum(value) as actual from b3139c; quit;

data _null_; if 0 then set b3139o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3139 rows=' rows;
else do; set b3139o; if not missing(actual) and abs(actual-(120))<=1e-9*max(1,abs(120)) then put 'ROUND7_PASS=B3139';
else put 'ERROR: ROUND7_FAIL=B3139 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3139:; quit;
