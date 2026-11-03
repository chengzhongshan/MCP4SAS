/* F1769 glm_cell_means, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1769a; do grp=1 to 2; do x=1 to 10; y=grp*x; output; end; end; run;
proc glm data=f1769a noprint; class grp; model y=grp; output out=f1769b p=predicted; quit;
proc sql; create table f1769c as select grp,mean(predicted) as pred from f1769b group by grp;
create table f1769o as select sum(pred) as actual from f1769c; quit;

data _null_; if 0 then set f1769o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1769 rows=' rows;
else do; set f1769o; if not missing(actual) and abs(actual-(16.5))<=1e-9*max(1,abs(16.5)) then put 'ROUND4_PASS=F1769';
else put 'ERROR: ROUND4_FAIL=F1769 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1769:; quit;
