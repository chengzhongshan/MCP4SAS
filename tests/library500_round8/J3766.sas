/* J3766 set_indsname_origin, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3766a; x=7; run; data j3766b; x=8; run;
data j3766c; set j3766a j3766b indsname=origin; flag=(upcase(origin)=upcase("WORK.j3766b")); run;
proc sql; create table j3766o as select sum(flag*x) as actual from j3766c; quit;

data _null_; if 0 then set j3766o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3766 rows=' rows;
else do; set j3766o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND8_PASS=J3766';
else put 'ERROR: ROUND8_FAIL=J3766 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3766:; quit;
