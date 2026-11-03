/* J3520 princomp_correlation_eigenvalue, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3520a; do j=1 to 11; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3520a outstat=j3520b noprint; var x y; run;
data j3520o; set j3520b; if _type_='EIGENVAL'; actual=x; run;

data _null_; if 0 then set j3520o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3520 rows=' rows;
else do; set j3520o; if not missing(actual) and abs(actual-(2))<=1e-6*max(1,abs(2)) then put 'ROUND8_PASS=J3520';
else put 'ERROR: ROUND8_FAIL=J3520 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3520:; quit;
