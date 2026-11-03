/* J3915 rank_normal_blom_symmetry, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3915a; do x=1 to 6+2; output; end; run;
proc rank data=j3915a out=j3915b normal=blom; var x; ranks score; run;
proc sql; create table j3915o as select sum(score) as actual from j3915b; quit;

data _null_; if 0 then set j3915o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3915 rows=' rows;
else do; set j3915o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3915';
else put 'ERROR: ROUND8_FAIL=J3915 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3915:; quit;
