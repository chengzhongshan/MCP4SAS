/* F1813 freq_sparse_cells, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1813a; do a=1 to 4; b=a; output; end; run;
proc freq data=f1813a noprint; tables a*b / sparse out=f1813b; run;
proc sql; create table f1813o as select sum(count=0) as actual from f1813b; quit;

data _null_; if 0 then set f1813o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1813 rows=' rows;
else do; set f1813o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND4_PASS=F1813';
else put 'ERROR: ROUND4_FAIL=F1813 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1813:; quit;
