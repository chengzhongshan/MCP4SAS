/* B3144 summary_ways_grand_and_class, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3144a; do grp=1 to 5; value=1; output; output; end; run;
proc summary data=b3144a; class grp; ways 0 1; var value; output out=b3144b sum=total; run;
proc sql; create table b3144o as select sum(_freq_)+count(*) as actual from b3144b; quit;

data _null_; if 0 then set b3144o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3144 rows=' rows;
else do; set b3144o; if not missing(actual) and abs(actual-(26))<=1e-9*max(1,abs(26)) then put 'ROUND7_PASS=B3144';
else put 'ERROR: ROUND7_FAIL=B3144 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3144:; quit;
