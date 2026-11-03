/* F1779 glm_residual_squares, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1779a; do grp=1 to 2; do x=1 to 10; y=grp*x; output; end; end; run;
proc glm data=f1779a noprint; class grp; model y=grp; output out=f1779b r=residual; quit;
proc sql; create table f1779o as select sum(residual*residual) as actual from f1779b; quit;

data _null_; if 0 then set f1779o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1779 rows=' rows;
else do; set f1779o; if not missing(actual) and abs(actual-(412.5))<=1e-9*max(1,abs(412.5)) then put 'ROUND4_PASS=F1779';
else put 'ERROR: ROUND4_FAIL=F1779 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1779:; quit;
