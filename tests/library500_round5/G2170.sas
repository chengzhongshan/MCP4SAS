/* G2170 sort_dupout, N=11; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data g2170a; do k=1 to 11; do value=1 to 3; output; end; end; run;
proc sort data=g2170a out=g2170b dupout=g2170c nodupkey equals; by k; run;
proc sql; create table g2170o as select count(*) as actual from g2170c; quit;

data _null_; if 0 then set g2170o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2170 rows=' rows;
else do; set g2170o; if not missing(actual) and abs(actual-(22))<=1e-9*max(1,abs(22)) then put 'ROUND5_PASS=G2170';
else put 'ERROR: ROUND5_FAIL=G2170 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2170:; quit;
