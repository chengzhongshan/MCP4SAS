/* J3753 by_descending_boundary_checksum, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:80 */

data j3753a; do grp=4 to 1 by -1; do j=1 to 2; output; end; end; run;
data j3753b; set j3753a; by descending grp; score=first.grp+10*last.grp; run;
proc sql; create table j3753o as select sum(score) as actual from j3753b; quit;

data _null_; if 0 then set j3753o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3753 rows=' rows;
else do; set j3753o; if not missing(actual) and abs(actual-(44))<=1e-9*max(1,abs(44)) then put 'ROUND8_PASS=J3753';
else put 'ERROR: ROUND8_FAIL=J3753 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3753:; quit;
