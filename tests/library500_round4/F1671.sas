/* F1671 corr_positive_affine, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1671a; do x=1 to 2+2; y=2+3*x; output; end; run;
proc corr data=f1671a outp=f1671b noprint; var x y; run;
data f1671o; set f1671b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1671o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1671 rows=' rows;
else do; set f1671o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1671';
else put 'ERROR: ROUND4_FAIL=F1671 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1671:; quit;
