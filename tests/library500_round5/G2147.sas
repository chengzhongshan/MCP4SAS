/* G2147 interleaving_set_by, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2147a; do k=1 to 8; value=k; output; end; run;
data g2147b; do k=1 to 8; value=10*k; output; end; run;
data g2147c; set g2147a g2147b; by k; weighted=value*_n_; run;
proc sql; create table g2147o as select sum(weighted) as actual from g2147c; quit;

data _null_; if 0 then set g2147o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2147 rows=' rows;
else do; set g2147o; if not missing(actual) and abs(actual-(4452))<=1e-9*max(1,abs(4452)) then put 'ROUND5_PASS=G2147';
else put 'ERROR: ROUND5_FAIL=G2147 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2147:; quit;
