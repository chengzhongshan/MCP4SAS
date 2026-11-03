/* F1819 freq_sparse_cells, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1819a; do a=1 to 10; b=a; output; end; run;
proc freq data=f1819a noprint; tables a*b / sparse out=f1819b; run;
proc sql; create table f1819o as select sum(count=0) as actual from f1819b; quit;

data _null_; if 0 then set f1819o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1819 rows=' rows;
else do; set f1819o; if not missing(actual) and abs(actual-(90))<=1e-9*max(1,abs(90)) then put 'ROUND4_PASS=F1819';
else put 'ERROR: ROUND4_FAIL=F1819 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1819:; quit;
