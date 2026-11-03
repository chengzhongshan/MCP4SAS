/* F1783 glm_class_covariate_exact, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1783a; do grp=1 to 2; do x=1 to 4; y=10*grp+2*x; output; end; end; run;
proc glm data=f1783a noprint; class grp; model y=grp x; output out=f1783b r=residual; quit;
proc sql; create table f1783o as select max(abs(residual)) as actual from f1783b; quit;

data _null_; if 0 then set f1783o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1783 rows=' rows;
else do; set f1783o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1783';
else put 'ERROR: ROUND4_FAIL=F1783 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1783:; quit;
