/* J3920 rank_normal_blom_symmetry, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3920a; do x=1 to 11+2; output; end; run;
proc rank data=j3920a out=j3920b normal=blom; var x; ranks score; run;
proc sql; create table j3920o as select sum(score) as actual from j3920b; quit;

data _null_; if 0 then set j3920o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3920 rows=' rows;
else do; set j3920o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3920';
else put 'ERROR: ROUND8_FAIL=J3920 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3920:; quit;
