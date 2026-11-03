/* J3916 rank_normal_blom_symmetry, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3916a; do x=1 to 7+2; output; end; run;
proc rank data=j3916a out=j3916b normal=blom; var x; ranks score; run;
proc sql; create table j3916o as select sum(score) as actual from j3916b; quit;

data _null_; if 0 then set j3916o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3916 rows=' rows;
else do; set j3916o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3916';
else put 'ERROR: ROUND8_FAIL=J3916 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3916:; quit;
