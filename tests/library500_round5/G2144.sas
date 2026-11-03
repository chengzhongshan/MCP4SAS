/* G2144 interleaving_set_by, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2144a; do k=1 to 5; value=k; output; end; run;
data g2144b; do k=1 to 5; value=10*k; output; end; run;
data g2144c; set g2144a g2144b; by k; weighted=value*_n_; run;
proc sql; create table g2144o as select sum(weighted) as actual from g2144c; quit;

data _null_; if 0 then set g2144o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2144 rows=' rows;
else do; set g2144o; if not missing(actual) and abs(actual-(1195))<=1e-9*max(1,abs(1195)) then put 'ROUND5_PASS=G2144';
else put 'ERROR: ROUND5_FAIL=G2144 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2144:; quit;
