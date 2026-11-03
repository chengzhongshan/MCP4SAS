/* J3911 rank_normal_blom_symmetry, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3911a; do x=1 to 2+2; output; end; run;
proc rank data=j3911a out=j3911b normal=blom; var x; ranks score; run;
proc sql; create table j3911o as select sum(score) as actual from j3911b; quit;

data _null_; if 0 then set j3911o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3911 rows=' rows;
else do; set j3911o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3911';
else put 'ERROR: ROUND8_FAIL=J3911 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3911:; quit;
