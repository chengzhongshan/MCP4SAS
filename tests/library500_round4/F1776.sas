/* F1776 glm_residual_squares, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1776a; do grp=1 to 2; do x=1 to 7; y=grp*x; output; end; end; run;
proc glm data=f1776a noprint; class grp; model y=grp; output out=f1776b r=residual; quit;
proc sql; create table f1776o as select sum(residual*residual) as actual from f1776b; quit;

data _null_; if 0 then set f1776o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1776 rows=' rows;
else do; set f1776o; if not missing(actual) and abs(actual-(140))<=1e-9*max(1,abs(140)) then put 'ROUND4_PASS=F1776';
else put 'ERROR: ROUND4_FAIL=F1776 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1776:; quit;
