/* F1782 glm_class_covariate_exact, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1782a; do grp=1 to 2; do x=1 to 3; y=10*grp+2*x; output; end; end; run;
proc glm data=f1782a noprint; class grp; model y=grp x; output out=f1782b r=residual; quit;
proc sql; create table f1782o as select max(abs(residual)) as actual from f1782b; quit;

data _null_; if 0 then set f1782o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1782 rows=' rows;
else do; set f1782o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1782';
else put 'ERROR: ROUND4_FAIL=F1782 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1782:; quit;
