/* F1717 corr_nomiss_listwise, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1717a; do x=1 to 8; y=3*x; output; end; x=.; y=999; output; run;
proc corr data=f1717a outp=f1717b nomiss noprint; var x y; run;
data f1717o; set f1717b; if _type_='MEAN'; actual=y; run;

data _null_; if 0 then set f1717o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1717 rows=' rows;
else do; set f1717o; if not missing(actual) and abs(actual-(13.5))<=1e-9*max(1,abs(13.5)) then put 'ROUND4_PASS=F1717';
else put 'ERROR: ROUND4_FAIL=F1717 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1717:; quit;
