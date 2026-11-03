/* J3946 compare_difference_output, N=7; source: SAS System for Mixed Models.txt:3276 */

data j3946a; do x=1 to 7; output; end; run;
data j3946b; set j3946a; x=x+2; run;
proc compare base=j3946a compare=j3946b out=j3946c outdif noprint; var x; run;
proc sql; create table j3946o as select sum(abs(x)) as actual from j3946c where _type_='DIF'; quit;

data _null_; if 0 then set j3946o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3946 rows=' rows;
else do; set j3946o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND8_PASS=J3946';
else put 'ERROR: ROUND8_FAIL=J3946 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3946:; quit;
