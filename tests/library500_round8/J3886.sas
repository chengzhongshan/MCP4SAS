/* J3886 summary_preloadfmt_empty_class, N=7; source: PROC TABULATE by Example.txt:3601 */

proc format; value j3886fmt 1='present' 2='absent'; run;
data j3886a; do j=1 to 7; grp=1; x=j; output; end; format grp j3886fmt.; run;
proc summary data=j3886a nway completetypes; class grp / preloadfmt; var x; output out=j3886b sum=total; run;
data j3886o; set j3886b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete j3886fmt.format; quit;

data _null_; if 0 then set j3886o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3886 rows=' rows;
else do; set j3886o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND8_PASS=J3886';
else put 'ERROR: ROUND8_FAIL=J3886 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3886:; quit;
