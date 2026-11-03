/* J3506 princomp_covariance_trace, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3506a; do j=1 to 7; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3506a cov outstat=j3506b noprint; var x y; run;
data j3506o; set j3506b; if _type_='EIGENVAL'; actual=sum(x,y); run;

data _null_; if 0 then set j3506o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3506 rows=' rows;
else do; set j3506o; if not missing(actual) and abs(actual-(107.692307692308))<=1e-6*max(1,abs(107.692307692308)) then put 'ROUND8_PASS=J3506';
else put 'ERROR: ROUND8_FAIL=J3506 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3506:; quit;
