/* J3522 princomp_eigenvector_norm, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3522a; do j=1 to 3; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3522a cov outstat=j3522b noprint; var x y; run;
data j3522o; set j3522b; if _type_='SCORE' and upcase(_name_)='PRIN1'; actual=x*x+y*y; run;

data _null_; if 0 then set j3522o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3522 rows=' rows;
else do; set j3522o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3522';
else put 'ERROR: ROUND8_FAIL=J3522 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3522:; quit;
