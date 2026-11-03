/* J3501 princomp_covariance_trace, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3501a; do j=1 to 2; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3501a cov outstat=j3501b noprint; var x y; run;
data j3501o; set j3501b; if _type_='EIGENVAL'; actual=sum(x,y); run;

data _null_; if 0 then set j3501o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3501 rows=' rows;
else do; set j3501o; if not missing(actual) and abs(actual-(16.6666666666667))<=1e-6*max(1,abs(16.6666666666667)) then put 'ROUND8_PASS=J3501';
else put 'ERROR: ROUND8_FAIL=J3501 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3501:; quit;
