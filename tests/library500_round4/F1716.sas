/* F1716 corr_nomiss_listwise, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1716a; do x=1 to 7; y=3*x; output; end; x=.; y=999; output; run;
proc corr data=f1716a outp=f1716b nomiss noprint; var x y; run;
data f1716o; set f1716b; if _type_='MEAN'; actual=y; run;

data _null_; if 0 then set f1716o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1716 rows=' rows;
else do; set f1716o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND4_PASS=F1716';
else put 'ERROR: ROUND4_FAIL=F1716 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1716:; quit;
