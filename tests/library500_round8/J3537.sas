/* J3537 princomp_score_energy, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3537a; do j=1 to 8; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3537a cov out=j3537b noprint; var x y; run;
proc sql; create table j3537o as select sum(prin1*prin1) as actual from j3537b; quit;

data _null_; if 0 then set j3537o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3537 rows=' rows;
else do; set j3537o; if not missing(actual) and abs(actual-(2040))<=1e-6*max(1,abs(2040)) then put 'ROUND8_PASS=J3537';
else put 'ERROR: ROUND8_FAIL=J3537 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3537:; quit;
