/* G2167 sort_dupout, N=8; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data g2167a; do k=1 to 8; do value=1 to 3; output; end; end; run;
proc sort data=g2167a out=g2167b dupout=g2167c nodupkey equals; by k; run;
proc sql; create table g2167o as select count(*) as actual from g2167c; quit;

data _null_; if 0 then set g2167o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2167 rows=' rows;
else do; set g2167o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND5_PASS=G2167';
else put 'ERROR: ROUND5_FAIL=G2167 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2167:; quit;
