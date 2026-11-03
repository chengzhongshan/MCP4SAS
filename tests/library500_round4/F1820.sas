/* F1820 freq_sparse_cells, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1820a; do a=1 to 11; b=a; output; end; run;
proc freq data=f1820a noprint; tables a*b / sparse out=f1820b; run;
proc sql; create table f1820o as select sum(count=0) as actual from f1820b; quit;

data _null_; if 0 then set f1820o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1820 rows=' rows;
else do; set f1820o; if not missing(actual) and abs(actual-(110))<=1e-9*max(1,abs(110)) then put 'ROUND4_PASS=F1820';
else put 'ERROR: ROUND4_FAIL=F1820 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1820:; quit;
