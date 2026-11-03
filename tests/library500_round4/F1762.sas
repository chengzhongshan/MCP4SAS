/* F1762 glm_cell_means, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1762a; do grp=1 to 2; do x=1 to 3; y=grp*x; output; end; end; run;
proc glm data=f1762a noprint; class grp; model y=grp; output out=f1762b p=predicted; quit;
proc sql; create table f1762c as select grp,mean(predicted) as pred from f1762b group by grp;
create table f1762o as select sum(pred) as actual from f1762c; quit;

data _null_; if 0 then set f1762o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1762 rows=' rows;
else do; set f1762o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1762';
else put 'ERROR: ROUND4_FAIL=F1762 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1762:; quit;
