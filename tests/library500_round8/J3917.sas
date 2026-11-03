/* J3917 rank_normal_blom_symmetry, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3917a; do x=1 to 8+2; output; end; run;
proc rank data=j3917a out=j3917b normal=blom; var x; ranks score; run;
proc sql; create table j3917o as select sum(score) as actual from j3917b; quit;

data _null_; if 0 then set j3917o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3917 rows=' rows;
else do; set j3917o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3917';
else put 'ERROR: ROUND8_FAIL=J3917 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3917:; quit;
