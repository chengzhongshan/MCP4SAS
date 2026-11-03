/* F1686 corr_negative_affine, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1686a; do x=1 to 7+2; y=7-3*x; output; end; run;
proc corr data=f1686a outp=f1686b noprint; var x y; run;
data f1686o; set f1686b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1686o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1686 rows=' rows;
else do; set f1686o; if not missing(actual) and abs(actual-(-1))<=1e-9*max(1,abs(-1)) then put 'ROUND4_PASS=F1686';
else put 'ERROR: ROUND4_FAIL=F1686 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1686:; quit;
