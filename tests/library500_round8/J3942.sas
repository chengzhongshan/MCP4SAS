/* J3942 compare_difference_output, N=3; source: SAS System for Mixed Models.txt:3276 */

data j3942a; do x=1 to 3; output; end; run;
data j3942b; set j3942a; x=x+2; run;
proc compare base=j3942a compare=j3942b out=j3942c outdif noprint; var x; run;
proc sql; create table j3942o as select sum(abs(x)) as actual from j3942c where _type_='DIF'; quit;

data _null_; if 0 then set j3942o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3942 rows=' rows;
else do; set j3942o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3942';
else put 'ERROR: ROUND8_FAIL=J3942 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3942:; quit;
