/* B3142 summary_ways_grand_and_class, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3142a; do grp=1 to 3; value=1; output; output; end; run;
proc summary data=b3142a; class grp; ways 0 1; var value; output out=b3142b sum=total; run;
proc sql; create table b3142o as select sum(_freq_)+count(*) as actual from b3142b; quit;

data _null_; if 0 then set b3142o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3142 rows=' rows;
else do; set b3142o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND7_PASS=B3142';
else put 'ERROR: ROUND7_FAIL=B3142 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3142:; quit;
