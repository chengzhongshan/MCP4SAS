/* B3094 multiple_set_shorter_stream, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data b3094a; do x=1 to 5+2; output; end; run;
data b3094b; do y=1 to 5; output; end; run;
data b3094c; set b3094a; set b3094b; value=x+y; run;
proc sql; create table b3094o as select sum(value) as actual from b3094c; quit;

data _null_; if 0 then set b3094o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3094 rows=' rows;
else do; set b3094o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND7_PASS=B3094';
else put 'ERROR: ROUND7_FAIL=B3094 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3094:; quit;
