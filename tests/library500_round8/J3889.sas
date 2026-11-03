/* J3889 summary_preloadfmt_empty_class, N=10; source: PROC TABULATE by Example.txt:3601 */

proc format; value j3889fmt 1='present' 2='absent'; run;
data j3889a; do j=1 to 10; grp=1; x=j; output; end; format grp j3889fmt.; run;
proc summary data=j3889a nway completetypes; class grp / preloadfmt; var x; output out=j3889b sum=total; run;
data j3889o; set j3889b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete j3889fmt.format; quit;

data _null_; if 0 then set j3889o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3889 rows=' rows;
else do; set j3889o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND8_PASS=J3889';
else put 'ERROR: ROUND8_FAIL=J3889 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3889:; quit;
