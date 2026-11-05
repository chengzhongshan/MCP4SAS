/* K4380 summary_classdata_empty_group, N=11; source: PROC TABULATE by Example.txt:739 */

data k4380a; do j=1 to 11; grp=1; x=j; output; end; run;
data k4380classes; grp=1; output; grp=2; output; run;
proc summary data=k4380a classdata=k4380classes nway completetypes; class grp; var x; output out=k4380b sum=total; run;
data k4380o; set k4380b; if grp=2; actual=_freq_; run;

data _null_; if 0 then set k4380o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4380 rows=' rows;
else do; set k4380o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND10_PASS=K4380';
else put 'ERROR: ROUND10_FAIL=K4380 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4380:; quit;
