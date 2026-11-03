/* F1679 corr_positive_affine, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1679a; do x=1 to 10+2; y=10+3*x; output; end; run;
proc corr data=f1679a outp=f1679b noprint; var x y; run;
data f1679o; set f1679b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1679o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1679 rows=' rows;
else do; set f1679o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1679';
else put 'ERROR: ROUND4_FAIL=F1679 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1679:; quit;
