/* J3913 rank_normal_blom_symmetry, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3913a; do x=1 to 4+2; output; end; run;
proc rank data=j3913a out=j3913b normal=blom; var x; ranks score; run;
proc sql; create table j3913o as select sum(score) as actual from j3913b; quit;

data _null_; if 0 then set j3913o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3913 rows=' rows;
else do; set j3913o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3913';
else put 'ERROR: ROUND8_FAIL=J3913 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3913:; quit;
