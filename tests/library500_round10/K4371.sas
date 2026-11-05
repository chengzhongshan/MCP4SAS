/* K4371 summary_classdata_empty_group, N=2; source: PROC TABULATE by Example.txt:739 */

data k4371a; do j=1 to 2; grp=1; x=j; output; end; run;
data k4371classes; grp=1; output; grp=2; output; run;
proc summary data=k4371a classdata=k4371classes nway completetypes; class grp; var x; output out=k4371b sum=total; run;
data k4371o; set k4371b; if grp=2; actual=_freq_; run;

data _null_; if 0 then set k4371o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4371 rows=' rows;
else do; set k4371o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND10_PASS=K4371';
else put 'ERROR: ROUND10_FAIL=K4371 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4371:; quit;
