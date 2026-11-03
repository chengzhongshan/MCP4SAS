/* J3882 summary_preloadfmt_empty_class, N=3; source: PROC TABULATE by Example.txt:3601 */

proc format; value j3882fmt 1='present' 2='absent'; run;
data j3882a; do j=1 to 3; grp=1; x=j; output; end; format grp j3882fmt.; run;
proc summary data=j3882a nway completetypes; class grp / preloadfmt; var x; output out=j3882b sum=total; run;
data j3882o; set j3882b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete j3882fmt.format; quit;

data _null_; if 0 then set j3882o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3882 rows=' rows;
else do; set j3882o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND8_PASS=J3882';
else put 'ERROR: ROUND8_FAIL=J3882 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3882:; quit;
