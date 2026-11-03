/* F1680 corr_positive_affine, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1680a; do x=1 to 11+2; y=11+3*x; output; end; run;
proc corr data=f1680a outp=f1680b noprint; var x y; run;
data f1680o; set f1680b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1680o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1680 rows=' rows;
else do; set f1680o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1680';
else put 'ERROR: ROUND4_FAIL=F1680 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1680:; quit;
