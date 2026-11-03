/* J3504 princomp_covariance_trace, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3504a; do j=1 to 5; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3504a cov outstat=j3504b noprint; var x y; run;
data j3504o; set j3504b; if _type_='EIGENVAL'; actual=sum(x,y); run;

data _null_; if 0 then set j3504o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3504 rows=' rows;
else do; set j3504o; if not missing(actual) and abs(actual-(61.1111111111111))<=1e-6*max(1,abs(61.1111111111111)) then put 'ROUND8_PASS=J3504';
else put 'ERROR: ROUND8_FAIL=J3504 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3504:; quit;
