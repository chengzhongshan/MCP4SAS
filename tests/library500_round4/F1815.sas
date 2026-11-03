/* F1815 freq_sparse_cells, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1815a; do a=1 to 6; b=a; output; end; run;
proc freq data=f1815a noprint; tables a*b / sparse out=f1815b; run;
proc sql; create table f1815o as select sum(count=0) as actual from f1815b; quit;

data _null_; if 0 then set f1815o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1815 rows=' rows;
else do; set f1815o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND4_PASS=F1815';
else put 'ERROR: ROUND4_FAIL=F1815 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1815:; quit;
