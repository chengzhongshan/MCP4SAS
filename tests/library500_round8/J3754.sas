/* J3754 by_descending_boundary_checksum, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:80 */

data j3754a; do grp=5 to 1 by -1; do j=1 to 2; output; end; end; run;
data j3754b; set j3754a; by descending grp; score=first.grp+10*last.grp; run;
proc sql; create table j3754o as select sum(score) as actual from j3754b; quit;

data _null_; if 0 then set j3754o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3754 rows=' rows;
else do; set j3754o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND8_PASS=J3754';
else put 'ERROR: ROUND8_FAIL=J3754 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3754:; quit;
