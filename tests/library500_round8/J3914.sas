/* J3914 rank_normal_blom_symmetry, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3914a; do x=1 to 5+2; output; end; run;
proc rank data=j3914a out=j3914b normal=blom; var x; ranks score; run;
proc sql; create table j3914o as select sum(score) as actual from j3914b; quit;

data _null_; if 0 then set j3914o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3914 rows=' rows;
else do; set j3914o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3914';
else put 'ERROR: ROUND8_FAIL=J3914 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3914:; quit;
