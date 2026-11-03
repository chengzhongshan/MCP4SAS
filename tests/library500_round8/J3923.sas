/* J3923 rank_normal_tukey_symmetry, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3923a; do x=1 to 4+2; output; end; run;
proc rank data=j3923a out=j3923b normal=tukey; var x; ranks score; run;
proc sql; create table j3923o as select sum(score) as actual from j3923b; quit;

data _null_; if 0 then set j3923o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3923 rows=' rows;
else do; set j3923o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3923';
else put 'ERROR: ROUND8_FAIL=J3923 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3923:; quit;
