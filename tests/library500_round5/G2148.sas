/* G2148 interleaving_set_by, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2148a; do k=1 to 9; value=k; output; end; run;
data g2148b; do k=1 to 9; value=10*k; output; end; run;
data g2148c; set g2148a g2148b; by k; weighted=value*_n_; run;
proc sql; create table g2148o as select sum(weighted) as actual from g2148c; quit;

data _null_; if 0 then set g2148o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2148 rows=' rows;
else do; set g2148o; if not missing(actual) and abs(actual-(6225))<=1e-9*max(1,abs(6225)) then put 'ROUND5_PASS=G2148';
else put 'ERROR: ROUND5_FAIL=G2148 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2148:; quit;
