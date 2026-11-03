/* J3525 princomp_eigenvector_norm, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3525a; do j=1 to 6; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3525a cov outstat=j3525b noprint; var x y; run;
data j3525o; set j3525b; if _type_='SCORE' and upcase(_name_)='PRIN1'; actual=x*x+y*y; run;

data _null_; if 0 then set j3525o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3525 rows=' rows;
else do; set j3525o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3525';
else put 'ERROR: ROUND8_FAIL=J3525 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3525:; quit;
