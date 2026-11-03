/* B3148 summary_ways_grand_and_class, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3148a; do grp=1 to 9; value=1; output; output; end; run;
proc summary data=b3148a; class grp; ways 0 1; var value; output out=b3148b sum=total; run;
proc sql; create table b3148o as select sum(_freq_)+count(*) as actual from b3148b; quit;

data _null_; if 0 then set b3148o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3148 rows=' rows;
else do; set b3148o; if not missing(actual) and abs(actual-(46))<=1e-9*max(1,abs(46)) then put 'ROUND7_PASS=B3148';
else put 'ERROR: ROUND7_FAIL=B3148 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3148:; quit;
