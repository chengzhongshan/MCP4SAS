/* J3756 by_descending_boundary_checksum, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:80 */

data j3756a; do grp=7 to 1 by -1; do j=1 to 2; output; end; end; run;
data j3756b; set j3756a; by descending grp; score=first.grp+10*last.grp; run;
proc sql; create table j3756o as select sum(score) as actual from j3756b; quit;

data _null_; if 0 then set j3756o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3756 rows=' rows;
else do; set j3756o; if not missing(actual) and abs(actual-(77))<=1e-9*max(1,abs(77)) then put 'ROUND8_PASS=J3756';
else put 'ERROR: ROUND8_FAIL=J3756 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3756:; quit;
