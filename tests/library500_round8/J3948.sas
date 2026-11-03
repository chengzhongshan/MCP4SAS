/* J3948 compare_difference_output, N=9; source: SAS System for Mixed Models.txt:3276 */

data j3948a; do x=1 to 9; output; end; run;
data j3948b; set j3948a; x=x+2; run;
proc compare base=j3948a compare=j3948b out=j3948c outdif noprint; var x; run;
proc sql; create table j3948o as select sum(abs(x)) as actual from j3948c where _type_='DIF'; quit;

data _null_; if 0 then set j3948o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3948 rows=' rows;
else do; set j3948o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND8_PASS=J3948';
else put 'ERROR: ROUND8_FAIL=J3948 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3948:; quit;
