/* J3508 princomp_covariance_trace, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3508a; do j=1 to 9; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3508a cov outstat=j3508b noprint; var x y; run;
data j3508o; set j3508b; if _type_='EIGENVAL'; actual=sum(x,y); run;

data _null_; if 0 then set j3508o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3508 rows=' rows;
else do; set j3508o; if not missing(actual) and abs(actual-(167.647058823529))<=1e-6*max(1,abs(167.647058823529)) then put 'ROUND8_PASS=J3508';
else put 'ERROR: ROUND8_FAIL=J3508 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3508:; quit;
