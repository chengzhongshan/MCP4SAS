/* F1715 corr_nomiss_listwise, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1715a; do x=1 to 6; y=3*x; output; end; x=.; y=999; output; run;
proc corr data=f1715a outp=f1715b nomiss noprint; var x y; run;
data f1715o; set f1715b; if _type_='MEAN'; actual=y; run;

data _null_; if 0 then set f1715o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1715 rows=' rows;
else do; set f1715o; if not missing(actual) and abs(actual-(10.5))<=1e-9*max(1,abs(10.5)) then put 'ROUND4_PASS=F1715';
else put 'ERROR: ROUND4_FAIL=F1715 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1715:; quit;
