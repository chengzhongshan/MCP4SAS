/* B3146 summary_ways_grand_and_class, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3146a; do grp=1 to 7; value=1; output; output; end; run;
proc summary data=b3146a; class grp; ways 0 1; var value; output out=b3146b sum=total; run;
proc sql; create table b3146o as select sum(_freq_)+count(*) as actual from b3146b; quit;

data _null_; if 0 then set b3146o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3146 rows=' rows;
else do; set b3146o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND7_PASS=B3146';
else put 'ERROR: ROUND7_FAIL=B3146 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3146:; quit;
