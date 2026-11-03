/* J3517 princomp_correlation_eigenvalue, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3517a; do j=1 to 8; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3517a outstat=j3517b noprint; var x y; run;
data j3517o; set j3517b; if _type_='EIGENVAL'; actual=x; run;

data _null_; if 0 then set j3517o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3517 rows=' rows;
else do; set j3517o; if not missing(actual) and abs(actual-(2))<=1e-6*max(1,abs(2)) then put 'ROUND8_PASS=J3517';
else put 'ERROR: ROUND8_FAIL=J3517 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3517:; quit;
