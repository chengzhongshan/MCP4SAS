/* G2168 sort_dupout, N=9; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data g2168a; do k=1 to 9; do value=1 to 3; output; end; end; run;
proc sort data=g2168a out=g2168b dupout=g2168c nodupkey equals; by k; run;
proc sql; create table g2168o as select count(*) as actual from g2168c; quit;

data _null_; if 0 then set g2168o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2168 rows=' rows;
else do; set g2168o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND5_PASS=G2168';
else put 'ERROR: ROUND5_FAIL=G2168 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2168:; quit;
