/* J3751 by_descending_boundary_checksum, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:80 */

data j3751a; do grp=2 to 1 by -1; do j=1 to 2; output; end; end; run;
data j3751b; set j3751a; by descending grp; score=first.grp+10*last.grp; run;
proc sql; create table j3751o as select sum(score) as actual from j3751b; quit;

data _null_; if 0 then set j3751o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3751 rows=' rows;
else do; set j3751o; if not missing(actual) and abs(actual-(22))<=1e-9*max(1,abs(22)) then put 'ROUND8_PASS=J3751';
else put 'ERROR: ROUND8_FAIL=J3751 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3751:; quit;
