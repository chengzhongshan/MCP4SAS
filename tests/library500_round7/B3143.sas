/* B3143 summary_ways_grand_and_class, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3143a; do grp=1 to 4; value=1; output; output; end; run;
proc summary data=b3143a; class grp; ways 0 1; var value; output out=b3143b sum=total; run;
proc sql; create table b3143o as select sum(_freq_)+count(*) as actual from b3143b; quit;

data _null_; if 0 then set b3143o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3143 rows=' rows;
else do; set b3143o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND7_PASS=B3143';
else put 'ERROR: ROUND7_FAIL=B3143 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3143:; quit;
