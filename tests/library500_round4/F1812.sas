/* F1812 freq_sparse_cells, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1812a; do a=1 to 3; b=a; output; end; run;
proc freq data=f1812a noprint; tables a*b / sparse out=f1812b; run;
proc sql; create table f1812o as select sum(count=0) as actual from f1812b; quit;

data _null_; if 0 then set f1812o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1812 rows=' rows;
else do; set f1812o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1812';
else put 'ERROR: ROUND4_FAIL=F1812 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1812:; quit;
