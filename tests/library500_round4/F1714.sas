/* F1714 corr_nomiss_listwise, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1714a; do x=1 to 5; y=3*x; output; end; x=.; y=999; output; run;
proc corr data=f1714a outp=f1714b nomiss noprint; var x y; run;
data f1714o; set f1714b; if _type_='MEAN'; actual=y; run;

data _null_; if 0 then set f1714o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1714 rows=' rows;
else do; set f1714o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND4_PASS=F1714';
else put 'ERROR: ROUND4_FAIL=F1714 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1714:; quit;
