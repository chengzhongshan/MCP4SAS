/* B3149 summary_ways_grand_and_class, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3149a; do grp=1 to 10; value=1; output; output; end; run;
proc summary data=b3149a; class grp; ways 0 1; var value; output out=b3149b sum=total; run;
proc sql; create table b3149o as select sum(_freq_)+count(*) as actual from b3149b; quit;

data _null_; if 0 then set b3149o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3149 rows=' rows;
else do; set b3149o; if not missing(actual) and abs(actual-(51))<=1e-9*max(1,abs(51)) then put 'ROUND7_PASS=B3149';
else put 'ERROR: ROUND7_FAIL=B3149 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3149:; quit;
