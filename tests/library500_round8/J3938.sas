/* J3938 rank_normal_vw_symmetry, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3938a; do x=1 to 9+2; output; end; run;
proc rank data=j3938a out=j3938b normal=vw; var x; ranks score; run;
proc sql; create table j3938o as select sum(score) as actual from j3938b; quit;

data _null_; if 0 then set j3938o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3938 rows=' rows;
else do; set j3938o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3938';
else put 'ERROR: ROUND8_FAIL=J3938 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3938:; quit;
