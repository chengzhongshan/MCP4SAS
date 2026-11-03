/* F1718 corr_nomiss_listwise, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1718a; do x=1 to 9; y=3*x; output; end; x=.; y=999; output; run;
proc corr data=f1718a outp=f1718b nomiss noprint; var x y; run;
data f1718o; set f1718b; if _type_='MEAN'; actual=y; run;

data _null_; if 0 then set f1718o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1718 rows=' rows;
else do; set f1718o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND4_PASS=F1718';
else put 'ERROR: ROUND4_FAIL=F1718 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1718:; quit;
