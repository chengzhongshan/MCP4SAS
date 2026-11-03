/* F1774 glm_residual_squares, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1774a; do grp=1 to 2; do x=1 to 5; y=grp*x; output; end; end; run;
proc glm data=f1774a noprint; class grp; model y=grp; output out=f1774b r=residual; quit;
proc sql; create table f1774o as select sum(residual*residual) as actual from f1774b; quit;

data _null_; if 0 then set f1774o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1774 rows=' rows;
else do; set f1774o; if not missing(actual) and abs(actual-(50))<=1e-9*max(1,abs(50)) then put 'ROUND4_PASS=F1774';
else put 'ERROR: ROUND4_FAIL=F1774 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1774:; quit;
