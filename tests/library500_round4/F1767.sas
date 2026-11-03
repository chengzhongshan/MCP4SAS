/* F1767 glm_cell_means, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1767a; do grp=1 to 2; do x=1 to 8; y=grp*x; output; end; end; run;
proc glm data=f1767a noprint; class grp; model y=grp; output out=f1767b p=predicted; quit;
proc sql; create table f1767c as select grp,mean(predicted) as pred from f1767b group by grp;
create table f1767o as select sum(pred) as actual from f1767c; quit;

data _null_; if 0 then set f1767o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1767 rows=' rows;
else do; set f1767o; if not missing(actual) and abs(actual-(13.5))<=1e-9*max(1,abs(13.5)) then put 'ROUND4_PASS=F1767';
else put 'ERROR: ROUND4_FAIL=F1767 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1767:; quit;
