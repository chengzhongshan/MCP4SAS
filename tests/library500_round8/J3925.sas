/* J3925 rank_normal_tukey_symmetry, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3925a; do x=1 to 6+2; output; end; run;
proc rank data=j3925a out=j3925b normal=tukey; var x; ranks score; run;
proc sql; create table j3925o as select sum(score) as actual from j3925b; quit;

data _null_; if 0 then set j3925o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3925 rows=' rows;
else do; set j3925o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3925';
else put 'ERROR: ROUND8_FAIL=J3925 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3925:; quit;
