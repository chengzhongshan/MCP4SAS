/* K4372 summary_classdata_empty_group, N=3; source: PROC TABULATE by Example.txt:739 */

data k4372a; do j=1 to 3; grp=1; x=j; output; end; run;
data k4372classes; grp=1; output; grp=2; output; run;
proc summary data=k4372a classdata=k4372classes nway completetypes; class grp; var x; output out=k4372b sum=total; run;
data k4372o; set k4372b; if grp=2; actual=_freq_; run;

data _null_; if 0 then set k4372o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4372 rows=' rows;
else do; set k4372o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND10_PASS=K4372';
else put 'ERROR: ROUND10_FAIL=K4372 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4372:; quit;
