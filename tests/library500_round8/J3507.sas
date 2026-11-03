/* J3507 princomp_covariance_trace, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3507a; do j=1 to 8; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3507a cov outstat=j3507b noprint; var x y; run;
data j3507o; set j3507b; if _type_='EIGENVAL'; actual=sum(x,y); run;

data _null_; if 0 then set j3507o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3507 rows=' rows;
else do; set j3507o; if not missing(actual) and abs(actual-(136))<=1e-6*max(1,abs(136)) then put 'ROUND8_PASS=J3507';
else put 'ERROR: ROUND8_FAIL=J3507 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3507:; quit;
