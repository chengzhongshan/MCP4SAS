/* F1787 glm_class_covariate_exact, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1787a; do grp=1 to 2; do x=1 to 8; y=10*grp+2*x; output; end; end; run;
proc glm data=f1787a noprint; class grp; model y=grp x; output out=f1787b r=residual; quit;
proc sql; create table f1787o as select max(abs(residual)) as actual from f1787b; quit;

data _null_; if 0 then set f1787o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1787 rows=' rows;
else do; set f1787o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1787';
else put 'ERROR: ROUND4_FAIL=F1787 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1787:; quit;
