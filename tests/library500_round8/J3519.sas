/* J3519 princomp_correlation_eigenvalue, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3519a; do j=1 to 10; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3519a outstat=j3519b noprint; var x y; run;
data j3519o; set j3519b; if _type_='EIGENVAL'; actual=x; run;

data _null_; if 0 then set j3519o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3519 rows=' rows;
else do; set j3519o; if not missing(actual) and abs(actual-(2))<=1e-6*max(1,abs(2)) then put 'ROUND8_PASS=J3519';
else put 'ERROR: ROUND8_FAIL=J3519 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3519:; quit;
