/* F1720 corr_nomiss_listwise, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1720a; do x=1 to 11; y=3*x; output; end; x=.; y=999; output; run;
proc corr data=f1720a outp=f1720b nomiss noprint; var x y; run;
data f1720o; set f1720b; if _type_='MEAN'; actual=y; run;

data _null_; if 0 then set f1720o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1720 rows=' rows;
else do; set f1720o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND4_PASS=F1720';
else put 'ERROR: ROUND4_FAIL=F1720 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1720:; quit;
