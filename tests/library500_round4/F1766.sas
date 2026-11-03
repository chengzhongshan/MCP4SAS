/* F1766 glm_cell_means, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1766a; do grp=1 to 2; do x=1 to 7; y=grp*x; output; end; end; run;
proc glm data=f1766a noprint; class grp; model y=grp; output out=f1766b p=predicted; quit;
proc sql; create table f1766c as select grp,mean(predicted) as pred from f1766b group by grp;
create table f1766o as select sum(pred) as actual from f1766c; quit;

data _null_; if 0 then set f1766o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1766 rows=' rows;
else do; set f1766o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND4_PASS=F1766';
else put 'ERROR: ROUND4_FAIL=F1766 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1766:; quit;
