/* J3930 rank_normal_tukey_symmetry, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1822 */

data j3930a; do x=1 to 11+2; output; end; run;
proc rank data=j3930a out=j3930b normal=tukey; var x; ranks score; run;
proc sql; create table j3930o as select sum(score) as actual from j3930b; quit;

data _null_; if 0 then set j3930o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3930 rows=' rows;
else do; set j3930o; if not missing(actual) and abs(actual-(0))<=1e-6*max(1,abs(0)) then put 'ROUND8_PASS=J3930';
else put 'ERROR: ROUND8_FAIL=J3930 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3930:; quit;
