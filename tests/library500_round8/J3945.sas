/* J3945 compare_difference_output, N=6; source: SAS System for Mixed Models.txt:3276 */

data j3945a; do x=1 to 6; output; end; run;
data j3945b; set j3945a; x=x+2; run;
proc compare base=j3945a compare=j3945b out=j3945c outdif noprint; var x; run;
proc sql; create table j3945o as select sum(abs(x)) as actual from j3945c where _type_='DIF'; quit;

data _null_; if 0 then set j3945o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3945 rows=' rows;
else do; set j3945o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND8_PASS=J3945';
else put 'ERROR: ROUND8_FAIL=J3945 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3945:; quit;
