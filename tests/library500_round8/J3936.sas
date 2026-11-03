/* J3936 rank_normal_vw_symmetry, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3936a; do x=1 to 7+2; output; end; run;
proc rank data=j3936a out=j3936b normal=vw; var x; ranks score; run;
proc sql; create table j3936o as select sum(score) as actual from j3936b; quit;

data _null_; if 0 then set j3936o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3936 rows=' rows;
else do; set j3936o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3936';
else put 'ERROR: ROUND8_FAIL=J3936 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3936:; quit;
