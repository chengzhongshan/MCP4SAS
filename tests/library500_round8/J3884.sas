/* J3884 summary_preloadfmt_empty_class, N=5; source: PROC TABULATE by Example.txt:3601 */

proc format; value j3884fmt 1='present' 2='absent'; run;
data j3884a; do j=1 to 5; grp=1; x=j; output; end; format grp j3884fmt.; run;
proc summary data=j3884a nway completetypes; class grp / preloadfmt; var x; output out=j3884b sum=total; run;
data j3884o; set j3884b; format grp; if grp=2; actual=_freq_; run;
proc catalog catalog=work.formats; delete j3884fmt.format; quit;

data _null_; if 0 then set j3884o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3884 rows=' rows;
else do; set j3884o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND8_PASS=J3884';
else put 'ERROR: ROUND8_FAIL=J3884 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3884:; quit;
