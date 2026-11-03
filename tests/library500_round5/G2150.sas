/* G2150 interleaving_set_by, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2150a; do k=1 to 11; value=k; output; end; run;
data g2150b; do k=1 to 11; value=10*k; output; end; run;
data g2150c; set g2150a g2150b; by k; weighted=value*_n_; run;
proc sql; create table g2150o as select sum(weighted) as actual from g2150c; quit;

data _null_; if 0 then set g2150o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2150 rows=' rows;
else do; set g2150o; if not missing(actual) and abs(actual-(11066))<=1e-9*max(1,abs(11066)) then put 'ROUND5_PASS=G2150';
else put 'ERROR: ROUND5_FAIL=G2150 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2150:; quit;
