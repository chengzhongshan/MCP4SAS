/* J3922 rank_normal_tukey_symmetry, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3922a; do x=1 to 3+2; output; end; run;
proc rank data=j3922a out=j3922b normal=tukey; var x; ranks score; run;
proc sql; create table j3922o as select sum(score) as actual from j3922b; quit;

data _null_; if 0 then set j3922o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3922 rows=' rows;
else do; set j3922o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3922';
else put 'ERROR: ROUND8_FAIL=J3922 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3922:; quit;
