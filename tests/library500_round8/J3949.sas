/* J3949 compare_difference_output, N=10; source: SAS System for Mixed Models.txt:3276 */

data j3949a; do x=1 to 10; output; end; run;
data j3949b; set j3949a; x=x+2; run;
proc compare base=j3949a compare=j3949b out=j3949c outdif noprint; var x; run;
proc sql; create table j3949o as select sum(abs(x)) as actual from j3949c where _type_='DIF'; quit;

data _null_; if 0 then set j3949o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3949 rows=' rows;
else do; set j3949o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND8_PASS=J3949';
else put 'ERROR: ROUND8_FAIL=J3949 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3949:; quit;
