/* F1818 freq_sparse_cells, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1818a; do a=1 to 9; b=a; output; end; run;
proc freq data=f1818a noprint; tables a*b / sparse out=f1818b; run;
proc sql; create table f1818o as select sum(count=0) as actual from f1818b; quit;

data _null_; if 0 then set f1818o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1818 rows=' rows;
else do; set f1818o; if not missing(actual) and abs(actual-(72))<=1e-9*max(1,abs(72)) then put 'ROUND4_PASS=F1818';
else put 'ERROR: ROUND4_FAIL=F1818 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1818:; quit;
