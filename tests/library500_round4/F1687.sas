/* F1687 corr_negative_affine, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1687a; do x=1 to 8+2; y=8-3*x; output; end; run;
proc corr data=f1687a outp=f1687b noprint; var x y; run;
data f1687o; set f1687b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1687o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1687 rows=' rows;
else do; set f1687o; if not missing(actual) and abs(actual-(-1))<=1e-9*max(1,abs(-1)) then put 'ROUND4_PASS=F1687';
else put 'ERROR: ROUND4_FAIL=F1687 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1687:; quit;
