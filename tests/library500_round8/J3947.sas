/* J3947 compare_difference_output, N=8; source: SAS System for Mixed Models.txt:3276 */

data j3947a; do x=1 to 8; output; end; run;
data j3947b; set j3947a; x=x+2; run;
proc compare base=j3947a compare=j3947b out=j3947c outdif noprint; var x; run;
proc sql; create table j3947o as select sum(abs(x)) as actual from j3947c where _type_='DIF'; quit;

data _null_; if 0 then set j3947o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3947 rows=' rows;
else do; set j3947o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND8_PASS=J3947';
else put 'ERROR: ROUND8_FAIL=J3947 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3947:; quit;
