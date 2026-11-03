/* F1780 glm_residual_squares, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1780a; do grp=1 to 2; do x=1 to 11; y=grp*x; output; end; end; run;
proc glm data=f1780a noprint; class grp; model y=grp; output out=f1780b r=residual; quit;
proc sql; create table f1780o as select sum(residual*residual) as actual from f1780b; quit;

data _null_; if 0 then set f1780o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1780 rows=' rows;
else do; set f1780o; if not missing(actual) and abs(actual-(550))<=1e-9*max(1,abs(550)) then put 'ROUND4_PASS=F1780';
else put 'ERROR: ROUND4_FAIL=F1780 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1780:; quit;
