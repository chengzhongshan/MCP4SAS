/* J3767 set_indsname_origin, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3767a; x=8; run; data j3767b; x=9; run;
data j3767c; set j3767a j3767b indsname=origin; flag=(upcase(origin)=upcase("WORK.j3767b")); run;
proc sql; create table j3767o as select sum(flag*x) as actual from j3767c; quit;

data _null_; if 0 then set j3767o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3767 rows=' rows;
else do; set j3767o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3767';
else put 'ERROR: ROUND8_FAIL=J3767 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3767:; quit;
