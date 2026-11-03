/* J3515 princomp_correlation_eigenvalue, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3515a; do j=1 to 6; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3515a outstat=j3515b noprint; var x y; run;
data j3515o; set j3515b; if _type_='EIGENVAL'; actual=x; run;

data _null_; if 0 then set j3515o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3515 rows=' rows;
else do; set j3515o; if not missing(actual) and abs(actual-(2))<=1e-6*max(1,abs(2)) then put 'ROUND8_PASS=J3515';
else put 'ERROR: ROUND8_FAIL=J3515 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3515:; quit;
