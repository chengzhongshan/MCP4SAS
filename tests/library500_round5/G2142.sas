/* G2142 interleaving_set_by, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2142a; do k=1 to 3; value=k; output; end; run;
data g2142b; do k=1 to 3; value=10*k; output; end; run;
data g2142c; set g2142a g2142b; by k; weighted=value*_n_; run;
proc sql; create table g2142o as select sum(weighted) as actual from g2142c; quit;

data _null_; if 0 then set g2142o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2142 rows=' rows;
else do; set g2142o; if not missing(actual) and abs(actual-(302))<=1e-9*max(1,abs(302)) then put 'ROUND5_PASS=G2142';
else put 'ERROR: ROUND5_FAIL=G2142 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2142:; quit;
