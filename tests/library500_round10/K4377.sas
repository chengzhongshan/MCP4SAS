/* K4377 summary_classdata_empty_group, N=8; source: PROC TABULATE by Example.txt:739 */

data k4377a; do j=1 to 8; grp=1; x=j; output; end; run;
data k4377classes; grp=1; output; grp=2; output; run;
proc summary data=k4377a classdata=k4377classes nway completetypes; class grp; var x; output out=k4377b sum=total; run;
data k4377o; set k4377b; if grp=2; actual=_freq_; run;

data _null_; if 0 then set k4377o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4377 rows=' rows;
else do; set k4377o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND10_PASS=K4377';
else put 'ERROR: ROUND10_FAIL=K4377 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4377:; quit;
