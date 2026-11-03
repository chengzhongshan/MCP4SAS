/* J3523 princomp_eigenvector_norm, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3523a; do j=1 to 4; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3523a cov outstat=j3523b noprint; var x y; run;
data j3523o; set j3523b; if _type_='SCORE' and upcase(_name_)='PRIN1'; actual=x*x+y*y; run;

data _null_; if 0 then set j3523o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3523 rows=' rows;
else do; set j3523o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3523';
else put 'ERROR: ROUND8_FAIL=J3523 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3523:; quit;
