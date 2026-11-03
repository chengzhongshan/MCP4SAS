/* F1775 glm_residual_squares, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1775a; do grp=1 to 2; do x=1 to 6; y=grp*x; output; end; end; run;
proc glm data=f1775a noprint; class grp; model y=grp; output out=f1775b r=residual; quit;
proc sql; create table f1775o as select sum(residual*residual) as actual from f1775b; quit;

data _null_; if 0 then set f1775o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1775 rows=' rows;
else do; set f1775o; if not missing(actual) and abs(actual-(87.5))<=1e-9*max(1,abs(87.5)) then put 'ROUND4_PASS=F1775';
else put 'ERROR: ROUND4_FAIL=F1775 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1775:; quit;
