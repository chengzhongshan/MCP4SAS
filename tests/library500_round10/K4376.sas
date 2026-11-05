/* K4376 summary_classdata_empty_group, N=7; source: PROC TABULATE by Example.txt:739 */

data k4376a; do j=1 to 7; grp=1; x=j; output; end; run;
data k4376classes; grp=1; output; grp=2; output; run;
proc summary data=k4376a classdata=k4376classes nway completetypes; class grp; var x; output out=k4376b sum=total; run;
data k4376o; set k4376b; if grp=2; actual=_freq_; run;

data _null_; if 0 then set k4376o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4376 rows=' rows;
else do; set k4376o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND10_PASS=K4376';
else put 'ERROR: ROUND10_FAIL=K4376 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4376:; quit;
