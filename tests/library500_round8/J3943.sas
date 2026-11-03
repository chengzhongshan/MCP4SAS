/* J3943 compare_difference_output, N=4; source: SAS System for Mixed Models.txt:3276 */

data j3943a; do x=1 to 4; output; end; run;
data j3943b; set j3943a; x=x+2; run;
proc compare base=j3943a compare=j3943b out=j3943c outdif noprint; var x; run;
proc sql; create table j3943o as select sum(abs(x)) as actual from j3943c where _type_='DIF'; quit;

data _null_; if 0 then set j3943o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3943 rows=' rows;
else do; set j3943o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND8_PASS=J3943';
else put 'ERROR: ROUND8_FAIL=J3943 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3943:; quit;
