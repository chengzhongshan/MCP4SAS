/* J3941 compare_difference_output, N=2; source: SAS System for Mixed Models.txt:3276 */

data j3941a; do x=1 to 2; output; end; run;
data j3941b; set j3941a; x=x+2; run;
proc compare base=j3941a compare=j3941b out=j3941c outdif noprint; var x; run;
proc sql; create table j3941o as select sum(abs(x)) as actual from j3941c where _type_='DIF'; quit;

data _null_; if 0 then set j3941o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3941 rows=' rows;
else do; set j3941o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND8_PASS=J3941';
else put 'ERROR: ROUND8_FAIL=J3941 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3941:; quit;
