/* B3141 summary_ways_grand_and_class, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3141a; do grp=1 to 2; value=1; output; output; end; run;
proc summary data=b3141a; class grp; ways 0 1; var value; output out=b3141b sum=total; run;
proc sql; create table b3141o as select sum(_freq_)+count(*) as actual from b3141b; quit;

data _null_; if 0 then set b3141o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3141 rows=' rows;
else do; set b3141o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND7_PASS=B3141';
else put 'ERROR: ROUND7_FAIL=B3141 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3141:; quit;
