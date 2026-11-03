/* J3950 compare_difference_output, N=11; source: SAS System for Mixed Models.txt:3276 */

data j3950a; do x=1 to 11; output; end; run;
data j3950b; set j3950a; x=x+2; run;
proc compare base=j3950a compare=j3950b out=j3950c outdif noprint; var x; run;
proc sql; create table j3950o as select sum(abs(x)) as actual from j3950c where _type_='DIF'; quit;

data _null_; if 0 then set j3950o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3950 rows=' rows;
else do; set j3950o; if not missing(actual) and abs(actual-(22))<=1e-9*max(1,abs(22)) then put 'ROUND8_PASS=J3950';
else put 'ERROR: ROUND8_FAIL=J3950 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3950:; quit;
