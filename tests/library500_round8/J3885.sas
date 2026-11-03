/* J3885 summary_preloadfmt_empty_class, N=6; source: PROC TABULATE by Example.txt:3601 */

proc format; value j3885fmt 1='present' 2='absent'; run;
data j3885a; do j=1 to 6; grp=1; x=j; output; end; format grp j3885fmt.; run;
proc summary data=j3885a nway completetypes; class grp / preloadfmt; var x; output out=j3885b sum=total; run;
data j3885o; set j3885b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete j3885fmt.format; quit;

data _null_; if 0 then set j3885o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3885 rows=' rows;
else do; set j3885o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND8_PASS=J3885';
else put 'ERROR: ROUND8_FAIL=J3885 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3885:; quit;
