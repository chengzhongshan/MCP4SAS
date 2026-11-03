/* F1778 glm_residual_squares, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1778a; do grp=1 to 2; do x=1 to 9; y=grp*x; output; end; end; run;
proc glm data=f1778a noprint; class grp; model y=grp; output out=f1778b r=residual; quit;
proc sql; create table f1778o as select sum(residual*residual) as actual from f1778b; quit;

data _null_; if 0 then set f1778o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1778 rows=' rows;
else do; set f1778o; if not missing(actual) and abs(actual-(300))<=1e-9*max(1,abs(300)) then put 'ROUND4_PASS=F1778';
else put 'ERROR: ROUND4_FAIL=F1778 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1778:; quit;
