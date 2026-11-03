/* B3150 summary_ways_grand_and_class, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3150a; do grp=1 to 11; value=1; output; output; end; run;
proc summary data=b3150a; class grp; ways 0 1; var value; output out=b3150b sum=total; run;
proc sql; create table b3150o as select sum(_freq_)+count(*) as actual from b3150b; quit;

data _null_; if 0 then set b3150o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3150 rows=' rows;
else do; set b3150o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND7_PASS=B3150';
else put 'ERROR: ROUND7_FAIL=B3150 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3150:; quit;
