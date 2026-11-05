/* K4374 summary_classdata_empty_group, N=5; source: PROC TABULATE by Example.txt:739 */

data k4374a; do j=1 to 5; grp=1; x=j; output; end; run;
data k4374classes; grp=1; output; grp=2; output; run;
proc summary data=k4374a classdata=k4374classes nway completetypes; class grp; var x; output out=k4374b sum=total; run;
data k4374o; set k4374b; if grp=2; actual=_freq_; run;

data _null_; if 0 then set k4374o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4374 rows=' rows;
else do; set k4374o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND10_PASS=K4374';
else put 'ERROR: ROUND10_FAIL=K4374 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4374:; quit;
