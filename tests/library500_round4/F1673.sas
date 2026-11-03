/* F1673 corr_positive_affine, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1673a; do x=1 to 4+2; y=4+3*x; output; end; run;
proc corr data=f1673a outp=f1673b noprint; var x y; run;
data f1673o; set f1673b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1673o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1673 rows=' rows;
else do; set f1673o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1673';
else put 'ERROR: ROUND4_FAIL=F1673 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1673:; quit;
