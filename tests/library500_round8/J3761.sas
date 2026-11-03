/* J3761 set_indsname_origin, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3761a; x=2; run; data j3761b; x=3; run;
data j3761c; set j3761a j3761b indsname=origin; flag=(upcase(origin)=upcase("WORK.j3761b")); run;
proc sql; create table j3761o as select sum(flag*x) as actual from j3761c; quit;

data _null_; if 0 then set j3761o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3761 rows=' rows;
else do; set j3761o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3761';
else put 'ERROR: ROUND8_FAIL=J3761 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3761:; quit;
