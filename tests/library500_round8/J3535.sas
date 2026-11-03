/* J3535 princomp_score_energy, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3535a; do j=1 to 6; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3535a cov out=j3535b noprint; var x y; run;
proc sql; create table j3535o as select sum(prin1*prin1) as actual from j3535b; quit;

data _null_; if 0 then set j3535o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3535 rows=' rows;
else do; set j3535o; if not missing(actual) and abs(actual-(910))<=1e-6*max(1,abs(910)) then put 'ROUND8_PASS=J3535';
else put 'ERROR: ROUND8_FAIL=J3535 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3535:; quit;
