/* G2143 interleaving_set_by, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2143a; do k=1 to 4; value=k; output; end; run;
data g2143b; do k=1 to 4; value=10*k; output; end; run;
data g2143c; set g2143a g2143b; by k; weighted=value*_n_; run;
proc sql; create table g2143o as select sum(weighted) as actual from g2143c; quit;

data _null_; if 0 then set g2143o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2143 rows=' rows;
else do; set g2143o; if not missing(actual) and abs(actual-(650))<=1e-9*max(1,abs(650)) then put 'ROUND5_PASS=G2143';
else put 'ERROR: ROUND5_FAIL=G2143 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2143:; quit;
