/* J3888 summary_preloadfmt_empty_class, N=9; source: PROC TABULATE by Example.txt:3601 */

proc format; value j3888fmt 1='present' 2='absent'; run;
data j3888a; do j=1 to 9; grp=1; x=j; output; end; format grp j3888fmt.; run;
proc summary data=j3888a nway completetypes; class grp / preloadfmt; var x; output out=j3888b sum=total; run;
data j3888o; set j3888b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete j3888fmt.format; quit;

data _null_; if 0 then set j3888o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3888 rows=' rows;
else do; set j3888o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND8_PASS=J3888';
else put 'ERROR: ROUND8_FAIL=J3888 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3888:; quit;
