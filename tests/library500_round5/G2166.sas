/* G2166 sort_dupout, N=7; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data g2166a; do k=1 to 7; do value=1 to 3; output; end; end; run;
proc sort data=g2166a out=g2166b dupout=g2166c nodupkey equals; by k; run;
proc sql; create table g2166o as select count(*) as actual from g2166c; quit;

data _null_; if 0 then set g2166o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2166 rows=' rows;
else do; set g2166o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND5_PASS=G2166';
else put 'ERROR: ROUND5_FAIL=G2166 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2166:; quit;
