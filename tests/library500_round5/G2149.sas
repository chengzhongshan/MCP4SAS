/* G2149 interleaving_set_by, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2149a; do k=1 to 10; value=k; output; end; run;
data g2149b; do k=1 to 10; value=10*k; output; end; run;
data g2149c; set g2149a g2149b; by k; weighted=value*_n_; run;
proc sql; create table g2149o as select sum(weighted) as actual from g2149c; quit;

data _null_; if 0 then set g2149o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2149 rows=' rows;
else do; set g2149o; if not missing(actual) and abs(actual-(8415))<=1e-9*max(1,abs(8415)) then put 'ROUND5_PASS=G2149';
else put 'ERROR: ROUND5_FAIL=G2149 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2149:; quit;
