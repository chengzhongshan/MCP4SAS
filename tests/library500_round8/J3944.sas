/* J3944 compare_difference_output, N=5; source: SAS System for Mixed Models.txt:3276 */

data j3944a; do x=1 to 5; output; end; run;
data j3944b; set j3944a; x=x+2; run;
proc compare base=j3944a compare=j3944b out=j3944c outdif noprint; var x; run;
proc sql; create table j3944o as select sum(abs(x)) as actual from j3944c where _type_='DIF'; quit;

data _null_; if 0 then set j3944o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3944 rows=' rows;
else do; set j3944o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3944';
else put 'ERROR: ROUND8_FAIL=J3944 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3944:; quit;
