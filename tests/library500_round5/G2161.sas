/* G2161 sort_dupout, N=2; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data g2161a; do k=1 to 2; do value=1 to 3; output; end; end; run;
proc sort data=g2161a out=g2161b dupout=g2161c nodupkey equals; by k; run;
proc sql; create table g2161o as select count(*) as actual from g2161c; quit;

data _null_; if 0 then set g2161o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2161 rows=' rows;
else do; set g2161o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2161';
else put 'ERROR: ROUND5_FAIL=G2161 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2161:; quit;
