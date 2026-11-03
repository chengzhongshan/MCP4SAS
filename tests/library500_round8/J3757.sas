/* J3757 by_descending_boundary_checksum, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:80 */

data j3757a; do grp=8 to 1 by -1; do j=1 to 2; output; end; end; run;
data j3757b; set j3757a; by descending grp; score=first.grp+10*last.grp; run;
proc sql; create table j3757o as select sum(score) as actual from j3757b; quit;

data _null_; if 0 then set j3757o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3757 rows=' rows;
else do; set j3757o; if not missing(actual) and abs(actual-(88))<=1e-9*max(1,abs(88)) then put 'ROUND8_PASS=J3757';
else put 'ERROR: ROUND8_FAIL=J3757 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3757:; quit;
