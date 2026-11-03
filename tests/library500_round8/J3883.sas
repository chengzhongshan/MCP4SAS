/* J3883 summary_preloadfmt_empty_class, N=4; source: PROC TABULATE by Example.txt:3601 */

proc format; value j3883fmt 1='present' 2='absent'; run;
data j3883a; do j=1 to 4; grp=1; x=j; output; end; format grp j3883fmt.; run;
proc summary data=j3883a nway completetypes; class grp / preloadfmt; var x; output out=j3883b sum=total; run;
data j3883o; set j3883b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete j3883fmt.format; quit;

data _null_; if 0 then set j3883o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3883 rows=' rows;
else do; set j3883o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND8_PASS=J3883';
else put 'ERROR: ROUND8_FAIL=J3883 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3883:; quit;
