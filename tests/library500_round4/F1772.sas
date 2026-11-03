/* F1772 glm_residual_squares, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1772a; do grp=1 to 2; do x=1 to 3; y=grp*x; output; end; end; run;
proc glm data=f1772a noprint; class grp; model y=grp; output out=f1772b r=residual; quit;
proc sql; create table f1772o as select sum(residual*residual) as actual from f1772b; quit;

data _null_; if 0 then set f1772o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1772 rows=' rows;
else do; set f1772o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1772';
else put 'ERROR: ROUND4_FAIL=F1772 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1772:; quit;
