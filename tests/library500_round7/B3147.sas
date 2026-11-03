/* B3147 summary_ways_grand_and_class, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3147a; do grp=1 to 8; value=1; output; output; end; run;
proc summary data=b3147a; class grp; ways 0 1; var value; output out=b3147b sum=total; run;
proc sql; create table b3147o as select sum(_freq_)+count(*) as actual from b3147b; quit;

data _null_; if 0 then set b3147o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3147 rows=' rows;
else do; set b3147o; if not missing(actual) and abs(actual-(41))<=1e-9*max(1,abs(41)) then put 'ROUND7_PASS=B3147';
else put 'ERROR: ROUND7_FAIL=B3147 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3147:; quit;
