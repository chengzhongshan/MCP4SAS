/* F1777 glm_residual_squares, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1777a; do grp=1 to 2; do x=1 to 8; y=grp*x; output; end; end; run;
proc glm data=f1777a noprint; class grp; model y=grp; output out=f1777b r=residual; quit;
proc sql; create table f1777o as select sum(residual*residual) as actual from f1777b; quit;

data _null_; if 0 then set f1777o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1777 rows=' rows;
else do; set f1777o; if not missing(actual) and abs(actual-(210))<=1e-9*max(1,abs(210)) then put 'ROUND4_PASS=F1777';
else put 'ERROR: ROUND4_FAIL=F1777 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1777:; quit;
