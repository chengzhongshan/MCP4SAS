/* J3765 set_indsname_origin, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3765a; x=6; run; data j3765b; x=7; run;
data j3765c; set j3765a j3765b indsname=origin; flag=(upcase(origin)=upcase("WORK.j3765b")); run;
proc sql; create table j3765o as select sum(flag*x) as actual from j3765c; quit;

data _null_; if 0 then set j3765o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3765 rows=' rows;
else do; set j3765o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3765';
else put 'ERROR: ROUND8_FAIL=J3765 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3765:; quit;
