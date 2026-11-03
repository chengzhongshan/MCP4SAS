/* F1676 corr_positive_affine, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1676a; do x=1 to 7+2; y=7+3*x; output; end; run;
proc corr data=f1676a outp=f1676b noprint; var x y; run;
data f1676o; set f1676b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1676o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1676 rows=' rows;
else do; set f1676o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1676';
else put 'ERROR: ROUND4_FAIL=F1676 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1676:; quit;
