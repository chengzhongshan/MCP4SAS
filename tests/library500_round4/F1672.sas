/* F1672 corr_positive_affine, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1672a; do x=1 to 3+2; y=3+3*x; output; end; run;
proc corr data=f1672a outp=f1672b noprint; var x y; run;
data f1672o; set f1672b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1672o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1672 rows=' rows;
else do; set f1672o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1672';
else put 'ERROR: ROUND4_FAIL=F1672 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1672:; quit;
