/* J3935 rank_normal_vw_symmetry, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3935a; do x=1 to 6+2; output; end; run;
proc rank data=j3935a out=j3935b normal=vw; var x; ranks score; run;
proc sql; create table j3935o as select sum(score) as actual from j3935b; quit;

data _null_; if 0 then set j3935o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3935 rows=' rows;
else do; set j3935o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3935';
else put 'ERROR: ROUND8_FAIL=J3935 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3935:; quit;
