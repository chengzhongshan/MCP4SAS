/* J3505 princomp_covariance_trace, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3505a; do j=1 to 6; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3505a cov outstat=j3505b noprint; var x y; run;
data j3505o; set j3505b; if _type_='EIGENVAL'; actual=sum(x,y); run;

data _null_; if 0 then set j3505o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3505 rows=' rows;
else do; set j3505o; if not missing(actual) and abs(actual-(82.7272727272727))<=1e-6*max(1,abs(82.7272727272727)) then put 'ROUND8_PASS=J3505';
else put 'ERROR: ROUND8_FAIL=J3505 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3505:; quit;
