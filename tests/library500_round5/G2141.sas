/* G2141 interleaving_set_by, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2141a; do k=1 to 2; value=k; output; end; run;
data g2141b; do k=1 to 2; value=10*k; output; end; run;
data g2141c; set g2141a g2141b; by k; weighted=value*_n_; run;
proc sql; create table g2141o as select sum(weighted) as actual from g2141c; quit;

data _null_; if 0 then set g2141o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2141 rows=' rows;
else do; set g2141o; if not missing(actual) and abs(actual-(107))<=1e-9*max(1,abs(107)) then put 'ROUND5_PASS=G2141';
else put 'ERROR: ROUND5_FAIL=G2141 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2141:; quit;
