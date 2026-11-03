/* F1768 glm_cell_means, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1768a; do grp=1 to 2; do x=1 to 9; y=grp*x; output; end; end; run;
proc glm data=f1768a noprint; class grp; model y=grp; output out=f1768b p=predicted; quit;
proc sql; create table f1768c as select grp,mean(predicted) as pred from f1768b group by grp;
create table f1768o as select sum(pred) as actual from f1768c; quit;

data _null_; if 0 then set f1768o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1768 rows=' rows;
else do; set f1768o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND4_PASS=F1768';
else put 'ERROR: ROUND4_FAIL=F1768 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1768:; quit;
