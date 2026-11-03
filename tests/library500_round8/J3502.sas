/* J3502 princomp_covariance_trace, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3502a; do j=1 to 3; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3502a cov outstat=j3502b noprint; var x y; run;
data j3502o; set j3502b; if _type_='EIGENVAL'; actual=sum(x,y); run;

data _null_; if 0 then set j3502o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3502 rows=' rows;
else do; set j3502o; if not missing(actual) and abs(actual-(28))<=1e-6*max(1,abs(28)) then put 'ROUND8_PASS=J3502';
else put 'ERROR: ROUND8_FAIL=J3502 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3502:; quit;
