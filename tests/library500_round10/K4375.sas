/* K4375 summary_classdata_empty_group, N=6; source: PROC TABULATE by Example.txt:739 */

data k4375a; do j=1 to 6; grp=1; x=j; output; end; run;
data k4375classes; grp=1; output; grp=2; output; run;
proc summary data=k4375a classdata=k4375classes nway completetypes; class grp; var x; output out=k4375b sum=total; run;
data k4375o; set k4375b; if grp=2; actual=_freq_; run;

data _null_; if 0 then set k4375o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4375 rows=' rows;
else do; set k4375o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND10_PASS=K4375';
else put 'ERROR: ROUND10_FAIL=K4375 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4375:; quit;
