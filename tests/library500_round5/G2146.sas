/* G2146 interleaving_set_by, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2146a; do k=1 to 7; value=k; output; end; run;
data g2146b; do k=1 to 7; value=10*k; output; end; run;
data g2146c; set g2146a g2146b; by k; weighted=value*_n_; run;
proc sql; create table g2146o as select sum(weighted) as actual from g2146c; quit;

data _null_; if 0 then set g2146o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2146 rows=' rows;
else do; set g2146o; if not missing(actual) and abs(actual-(3052))<=1e-9*max(1,abs(3052)) then put 'ROUND5_PASS=G2146';
else put 'ERROR: ROUND5_FAIL=G2146 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2146:; quit;
