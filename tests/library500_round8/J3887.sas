/* J3887 summary_preloadfmt_empty_class, N=8; source: PROC TABULATE by Example.txt:3601 */

proc format; value j3887fmt 1='present' 2='absent'; run;
data j3887a; do j=1 to 8; grp=1; x=j; output; end; format grp j3887fmt.; run;
proc summary data=j3887a nway completetypes; class grp / preloadfmt; var x; output out=j3887b sum=total; run;
data j3887o; set j3887b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete j3887fmt.format; quit;

data _null_; if 0 then set j3887o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3887 rows=' rows;
else do; set j3887o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND8_PASS=J3887';
else put 'ERROR: ROUND8_FAIL=J3887 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3887:; quit;
