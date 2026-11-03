/* J3510 princomp_covariance_trace, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3510a; do j=1 to 11; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3510a cov outstat=j3510b noprint; var x y; run;
data j3510o; set j3510b; if _type_='EIGENVAL'; actual=sum(x,y); run;

data _null_; if 0 then set j3510o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3510 rows=' rows;
else do; set j3510o; if not missing(actual) and abs(actual-(240.952380952381))<=1e-6*max(1,abs(240.952380952381)) then put 'ROUND8_PASS=J3510';
else put 'ERROR: ROUND8_FAIL=J3510 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3510:; quit;
