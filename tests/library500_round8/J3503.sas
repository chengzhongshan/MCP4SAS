/* J3503 princomp_covariance_trace, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3503a; do j=1 to 4; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3503a cov outstat=j3503b noprint; var x y; run;
data j3503o; set j3503b; if _type_='EIGENVAL'; actual=sum(x,y); run;

data _null_; if 0 then set j3503o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3503 rows=' rows;
else do; set j3503o; if not missing(actual) and abs(actual-(42.8571428571429))<=1e-6*max(1,abs(42.8571428571429)) then put 'ROUND8_PASS=J3503';
else put 'ERROR: ROUND8_FAIL=J3503 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3503:; quit;
