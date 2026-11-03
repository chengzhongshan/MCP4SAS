/* G2165 sort_dupout, N=6; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data g2165a; do k=1 to 6; do value=1 to 3; output; end; end; run;
proc sort data=g2165a out=g2165b dupout=g2165c nodupkey equals; by k; run;
proc sql; create table g2165o as select count(*) as actual from g2165c; quit;

data _null_; if 0 then set g2165o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2165 rows=' rows;
else do; set g2165o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND5_PASS=G2165';
else put 'ERROR: ROUND5_FAIL=G2165 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2165:; quit;
