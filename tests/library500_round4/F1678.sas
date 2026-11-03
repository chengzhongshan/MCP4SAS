/* F1678 corr_positive_affine, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1678a; do x=1 to 9+2; y=9+3*x; output; end; run;
proc corr data=f1678a outp=f1678b noprint; var x y; run;
data f1678o; set f1678b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1678o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1678 rows=' rows;
else do; set f1678o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1678';
else put 'ERROR: ROUND4_FAIL=F1678 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1678:; quit;
