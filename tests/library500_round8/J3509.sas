/* J3509 princomp_covariance_trace, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3509a; do j=1 to 10; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3509a cov outstat=j3509b noprint; var x y; run;
data j3509o; set j3509b; if _type_='EIGENVAL'; actual=sum(x,y); run;

data _null_; if 0 then set j3509o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3509 rows=' rows;
else do; set j3509o; if not missing(actual) and abs(actual-(202.631578947368))<=1e-6*max(1,abs(202.631578947368)) then put 'ROUND8_PASS=J3509';
else put 'ERROR: ROUND8_FAIL=J3509 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3509:; quit;
