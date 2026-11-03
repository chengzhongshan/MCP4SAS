/* B3097 multiple_set_shorter_stream, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data b3097a; do x=1 to 8+2; output; end; run;
data b3097b; do y=1 to 8; output; end; run;
data b3097c; set b3097a; set b3097b; value=x+y; run;
proc sql; create table b3097o as select sum(value) as actual from b3097c; quit;

data _null_; if 0 then set b3097o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3097 rows=' rows;
else do; set b3097o; if not missing(actual) and abs(actual-(72))<=1e-9*max(1,abs(72)) then put 'ROUND7_PASS=B3097';
else put 'ERROR: ROUND7_FAIL=B3097 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3097:; quit;
