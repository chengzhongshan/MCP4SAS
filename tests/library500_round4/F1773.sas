/* F1773 glm_residual_squares, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1773a; do grp=1 to 2; do x=1 to 4; y=grp*x; output; end; end; run;
proc glm data=f1773a noprint; class grp; model y=grp; output out=f1773b r=residual; quit;
proc sql; create table f1773o as select sum(residual*residual) as actual from f1773b; quit;

data _null_; if 0 then set f1773o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1773 rows=' rows;
else do; set f1773o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND4_PASS=F1773';
else put 'ERROR: ROUND4_FAIL=F1773 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1773:; quit;
