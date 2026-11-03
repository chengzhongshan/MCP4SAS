/* J3881 summary_preloadfmt_empty_class, N=2; source: PROC TABULATE by Example.txt:3601 */

proc format; value j3881fmt 1='present' 2='absent'; run;
data j3881a; do j=1 to 2; grp=1; x=j; output; end; format grp j3881fmt.; run;
proc summary data=j3881a nway completetypes; class grp / preloadfmt; var x; output out=j3881b sum=total; run;
data j3881o; set j3881b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete j3881fmt.format; quit;

data _null_; if 0 then set j3881o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3881 rows=' rows;
else do; set j3881o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND8_PASS=J3881';
else put 'ERROR: ROUND8_FAIL=J3881 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3881:; quit;
