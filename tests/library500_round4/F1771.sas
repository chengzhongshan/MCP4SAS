/* F1771 glm_residual_squares, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1771a; do grp=1 to 2; do x=1 to 2; y=grp*x; output; end; end; run;
proc glm data=f1771a noprint; class grp; model y=grp; output out=f1771b r=residual; quit;
proc sql; create table f1771o as select sum(residual*residual) as actual from f1771b; quit;

data _null_; if 0 then set f1771o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1771 rows=' rows;
else do; set f1771o; if not missing(actual) and abs(actual-(2.5))<=1e-9*max(1,abs(2.5)) then put 'ROUND4_PASS=F1771';
else put 'ERROR: ROUND4_FAIL=F1771 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1771:; quit;
