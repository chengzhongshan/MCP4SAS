/* J3758 by_descending_boundary_checksum, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:80 */

data j3758a; do grp=9 to 1 by -1; do j=1 to 2; output; end; end; run;
data j3758b; set j3758a; by descending grp; score=first.grp+10*last.grp; run;
proc sql; create table j3758o as select sum(score) as actual from j3758b; quit;

data _null_; if 0 then set j3758o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3758 rows=' rows;
else do; set j3758o; if not missing(actual) and abs(actual-(99))<=1e-9*max(1,abs(99)) then put 'ROUND8_PASS=J3758';
else put 'ERROR: ROUND8_FAIL=J3758 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3758:; quit;
