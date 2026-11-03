/* J3518 princomp_correlation_eigenvalue, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3518a; do j=1 to 9; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3518a outstat=j3518b noprint; var x y; run;
data j3518o; set j3518b; if _type_='EIGENVAL'; actual=x; run;

data _null_; if 0 then set j3518o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3518 rows=' rows;
else do; set j3518o; if not missing(actual) and abs(actual-(2))<=1e-6*max(1,abs(2)) then put 'ROUND8_PASS=J3518';
else put 'ERROR: ROUND8_FAIL=J3518 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3518:; quit;
