/* J3924 rank_normal_tukey_symmetry, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3924a; do x=1 to 5+2; output; end; run;
proc rank data=j3924a out=j3924b normal=tukey; var x; ranks score; run;
proc sql; create table j3924o as select sum(score) as actual from j3924b; quit;

data _null_; if 0 then set j3924o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3924 rows=' rows;
else do; set j3924o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3924';
else put 'ERROR: ROUND8_FAIL=J3924 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3924:; quit;
