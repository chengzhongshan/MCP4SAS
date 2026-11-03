/* J3752 by_descending_boundary_checksum, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:80 */

data j3752a; do grp=3 to 1 by -1; do j=1 to 2; output; end; end; run;
data j3752b; set j3752a; by descending grp; score=first.grp+10*last.grp; run;
proc sql; create table j3752o as select sum(score) as actual from j3752b; quit;

data _null_; if 0 then set j3752o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3752 rows=' rows;
else do; set j3752o; if not missing(actual) and abs(actual-(33))<=1e-9*max(1,abs(33)) then put 'ROUND8_PASS=J3752';
else put 'ERROR: ROUND8_FAIL=J3752 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3752:; quit;
