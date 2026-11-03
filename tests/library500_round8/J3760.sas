/* J3760 by_descending_boundary_checksum, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:80 */

data j3760a; do grp=11 to 1 by -1; do j=1 to 2; output; end; end; run;
data j3760b; set j3760a; by descending grp; score=first.grp+10*last.grp; run;
proc sql; create table j3760o as select sum(score) as actual from j3760b; quit;

data _null_; if 0 then set j3760o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3760 rows=' rows;
else do; set j3760o; if not missing(actual) and abs(actual-(121))<=1e-9*max(1,abs(121)) then put 'ROUND8_PASS=J3760';
else put 'ERROR: ROUND8_FAIL=J3760 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3760:; quit;
