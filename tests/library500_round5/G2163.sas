/* G2163 sort_dupout, N=4; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data g2163a; do k=1 to 4; do value=1 to 3; output; end; end; run;
proc sort data=g2163a out=g2163b dupout=g2163c nodupkey equals; by k; run;
proc sql; create table g2163o as select count(*) as actual from g2163c; quit;

data _null_; if 0 then set g2163o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2163 rows=' rows;
else do; set g2163o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2163';
else put 'ERROR: ROUND5_FAIL=G2163 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2163:; quit;
