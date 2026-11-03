/* G2164 sort_dupout, N=5; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data g2164a; do k=1 to 5; do value=1 to 3; output; end; end; run;
proc sort data=g2164a out=g2164b dupout=g2164c nodupkey equals; by k; run;
proc sql; create table g2164o as select count(*) as actual from g2164c; quit;

data _null_; if 0 then set g2164o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2164 rows=' rows;
else do; set g2164o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2164';
else put 'ERROR: ROUND5_FAIL=G2164 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2164:; quit;
