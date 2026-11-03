/* B3145 summary_ways_grand_and_class, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3145a; do grp=1 to 6; value=1; output; output; end; run;
proc summary data=b3145a; class grp; ways 0 1; var value; output out=b3145b sum=total; run;
proc sql; create table b3145o as select sum(_freq_)+count(*) as actual from b3145b; quit;

data _null_; if 0 then set b3145o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3145 rows=' rows;
else do; set b3145o; if not missing(actual) and abs(actual-(31))<=1e-9*max(1,abs(31)) then put 'ROUND7_PASS=B3145';
else put 'ERROR: ROUND7_FAIL=B3145 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3145:; quit;
