/* B3064 do_list_and_range, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data b3064a; do x=1 to 5,2*5; output; end; run;
proc sql; create table b3064o as select sum(x) as actual from b3064a; quit;

data _null_; if 0 then set b3064o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3064 rows=' rows;
else do; set b3064o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND7_PASS=B3064';
else put 'ERROR: ROUND7_FAIL=B3064 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3064:; quit;
