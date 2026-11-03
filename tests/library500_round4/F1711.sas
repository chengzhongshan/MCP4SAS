/* F1711 corr_nomiss_listwise, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1711a; do x=1 to 2; y=3*x; output; end; x=.; y=999; output; run;
proc corr data=f1711a outp=f1711b nomiss noprint; var x y; run;
data f1711o; set f1711b; if _type_='MEAN'; actual=y; run;

data _null_; if 0 then set f1711o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1711 rows=' rows;
else do; set f1711o; if not missing(actual) and abs(actual-(4.5))<=1e-9*max(1,abs(4.5)) then put 'ROUND4_PASS=F1711';
else put 'ERROR: ROUND4_FAIL=F1711 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1711:; quit;
