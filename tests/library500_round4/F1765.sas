/* F1765 glm_cell_means, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1765a; do grp=1 to 2; do x=1 to 6; y=grp*x; output; end; end; run;
proc glm data=f1765a noprint; class grp; model y=grp; output out=f1765b p=predicted; quit;
proc sql; create table f1765c as select grp,mean(predicted) as pred from f1765b group by grp;
create table f1765o as select sum(pred) as actual from f1765c; quit;

data _null_; if 0 then set f1765o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1765 rows=' rows;
else do; set f1765o; if not missing(actual) and abs(actual-(10.5))<=1e-9*max(1,abs(10.5)) then put 'ROUND4_PASS=F1765';
else put 'ERROR: ROUND4_FAIL=F1765 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1765:; quit;
