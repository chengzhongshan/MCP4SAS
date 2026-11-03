/* F1712 corr_nomiss_listwise, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1712a; do x=1 to 3; y=3*x; output; end; x=.; y=999; output; run;
proc corr data=f1712a outp=f1712b nomiss noprint; var x y; run;
data f1712o; set f1712b; if _type_='MEAN'; actual=y; run;

data _null_; if 0 then set f1712o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1712 rows=' rows;
else do; set f1712o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1712';
else put 'ERROR: ROUND4_FAIL=F1712 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1712:; quit;
