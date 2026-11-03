/* J3918 rank_normal_blom_symmetry, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3918a; do x=1 to 9+2; output; end; run;
proc rank data=j3918a out=j3918b normal=blom; var x; ranks score; run;
proc sql; create table j3918o as select sum(score) as actual from j3918b; quit;

data _null_; if 0 then set j3918o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3918 rows=' rows;
else do; set j3918o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3918';
else put 'ERROR: ROUND8_FAIL=J3918 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3918:; quit;
