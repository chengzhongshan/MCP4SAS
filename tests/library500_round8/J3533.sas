/* J3533 princomp_score_energy, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3533a; do j=1 to 4; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3533a cov out=j3533b noprint; var x y; run;
proc sql; create table j3533o as select sum(prin1*prin1) as actual from j3533b; quit;

data _null_; if 0 then set j3533o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3533 rows=' rows;
else do; set j3533o; if not missing(actual) and abs(actual-(300))<=1e-6*max(1,abs(300)) then put 'ROUND8_PASS=J3533';
else put 'ERROR: ROUND8_FAIL=J3533 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3533:; quit;
