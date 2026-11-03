/* J3929 rank_normal_tukey_symmetry, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3929a; do x=1 to 10+2; output; end; run;
proc rank data=j3929a out=j3929b normal=tukey; var x; ranks score; run;
proc sql; create table j3929o as select sum(score) as actual from j3929b; quit;

data _null_; if 0 then set j3929o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3929 rows=' rows;
else do; set j3929o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3929';
else put 'ERROR: ROUND8_FAIL=J3929 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3929:; quit;
