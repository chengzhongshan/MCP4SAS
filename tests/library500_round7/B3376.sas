/* B3376 rank_percent_sum, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3376a; do x=1 to 7; output; end; run;
proc rank data=b3376a out=b3376b percent; var x; ranks percent; run;
proc sql; create table b3376o as select sum(percent) as actual from b3376b; quit;

data _null_; if 0 then set b3376o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3376 rows=' rows;
else do; set b3376o; if not missing(actual) and abs(actual-(400))<=1e-9*max(1,abs(400)) then put 'ROUND7_PASS=B3376';
else put 'ERROR: ROUND7_FAIL=B3376 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3376:; quit;
