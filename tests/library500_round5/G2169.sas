/* G2169 sort_dupout, N=10; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data g2169a; do k=1 to 10; do value=1 to 3; output; end; end; run;
proc sort data=g2169a out=g2169b dupout=g2169c nodupkey equals; by k; run;
proc sql; create table g2169o as select count(*) as actual from g2169c; quit;

data _null_; if 0 then set g2169o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2169 rows=' rows;
else do; set g2169o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND5_PASS=G2169';
else put 'ERROR: ROUND5_FAIL=G2169 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2169:; quit;
