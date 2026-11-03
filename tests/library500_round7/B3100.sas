/* B3100 multiple_set_shorter_stream, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data b3100a; do x=1 to 11+2; output; end; run;
data b3100b; do y=1 to 11; output; end; run;
data b3100c; set b3100a; set b3100b; value=x+y; run;
proc sql; create table b3100o as select sum(value) as actual from b3100c; quit;

data _null_; if 0 then set b3100o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3100 rows=' rows;
else do; set b3100o; if not missing(actual) and abs(actual-(132))<=1e-9*max(1,abs(132)) then put 'ROUND7_PASS=B3100';
else put 'ERROR: ROUND7_FAIL=B3100 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3100:; quit;
