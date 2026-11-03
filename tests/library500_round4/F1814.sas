/* F1814 freq_sparse_cells, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1814a; do a=1 to 5; b=a; output; end; run;
proc freq data=f1814a noprint; tables a*b / sparse out=f1814b; run;
proc sql; create table f1814o as select sum(count=0) as actual from f1814b; quit;

data _null_; if 0 then set f1814o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1814 rows=' rows;
else do; set f1814o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND4_PASS=F1814';
else put 'ERROR: ROUND4_FAIL=F1814 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1814:; quit;
