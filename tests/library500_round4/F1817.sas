/* F1817 freq_sparse_cells, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1817a; do a=1 to 8; b=a; output; end; run;
proc freq data=f1817a noprint; tables a*b / sparse out=f1817b; run;
proc sql; create table f1817o as select sum(count=0) as actual from f1817b; quit;

data _null_; if 0 then set f1817o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1817 rows=' rows;
else do; set f1817o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND4_PASS=F1817';
else put 'ERROR: ROUND4_FAIL=F1817 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1817:; quit;
