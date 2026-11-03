/* F1811 freq_sparse_cells, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1811a; do a=1 to 2; b=a; output; end; run;
proc freq data=f1811a noprint; tables a*b / sparse out=f1811b; run;
proc sql; create table f1811o as select sum(count=0) as actual from f1811b; quit;

data _null_; if 0 then set f1811o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1811 rows=' rows;
else do; set f1811o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1811';
else put 'ERROR: ROUND4_FAIL=F1811 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1811:; quit;
