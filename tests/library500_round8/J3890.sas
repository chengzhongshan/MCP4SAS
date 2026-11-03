/* J3890 summary_preloadfmt_empty_class, N=11; source: PROC TABULATE by Example.txt:3601 */

proc format; value j3890fmt 1='present' 2='absent'; run;
data j3890a; do j=1 to 11; grp=1; x=j; output; end; format grp j3890fmt.; run;
proc summary data=j3890a nway completetypes; class grp / preloadfmt; var x; output out=j3890b sum=total; run;
data j3890o; set j3890b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete j3890fmt.format; quit;

data _null_; if 0 then set j3890o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3890 rows=' rows;
else do; set j3890o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND8_PASS=J3890';
else put 'ERROR: ROUND8_FAIL=J3890 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3890:; quit;
