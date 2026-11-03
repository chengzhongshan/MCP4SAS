/* G2145 interleaving_set_by, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2145a; do k=1 to 6; value=k; output; end; run;
data g2145b; do k=1 to 6; value=10*k; output; end; run;
data g2145c; set g2145a g2145b; by k; weighted=value*_n_; run;
proc sql; create table g2145o as select sum(weighted) as actual from g2145c; quit;

data _null_; if 0 then set g2145o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2145 rows=' rows;
else do; set g2145o; if not missing(actual) and abs(actual-(1981))<=1e-9*max(1,abs(1981)) then put 'ROUND5_PASS=G2145';
else put 'ERROR: ROUND5_FAIL=G2145 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2145:; quit;
