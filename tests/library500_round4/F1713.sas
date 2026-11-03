/* F1713 corr_nomiss_listwise, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1713a; do x=1 to 4; y=3*x; output; end; x=.; y=999; output; run;
proc corr data=f1713a outp=f1713b nomiss noprint; var x y; run;
data f1713o; set f1713b; if _type_='MEAN'; actual=y; run;

data _null_; if 0 then set f1713o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1713 rows=' rows;
else do; set f1713o; if not missing(actual) and abs(actual-(7.5))<=1e-9*max(1,abs(7.5)) then put 'ROUND4_PASS=F1713';
else put 'ERROR: ROUND4_FAIL=F1713 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1713:; quit;
