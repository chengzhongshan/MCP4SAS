/* F1816 freq_sparse_cells, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1816a; do a=1 to 7; b=a; output; end; run;
proc freq data=f1816a noprint; tables a*b / sparse out=f1816b; run;
proc sql; create table f1816o as select sum(count=0) as actual from f1816b; quit;

data _null_; if 0 then set f1816o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1816 rows=' rows;
else do; set f1816o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND4_PASS=F1816';
else put 'ERROR: ROUND4_FAIL=F1816 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1816:; quit;
