/* F1761 glm_cell_means, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1761a; do grp=1 to 2; do x=1 to 2; y=grp*x; output; end; end; run;
proc glm data=f1761a noprint; class grp; model y=grp; output out=f1761b p=predicted; quit;
proc sql; create table f1761c as select grp,mean(predicted) as pred from f1761b group by grp;
create table f1761o as select sum(pred) as actual from f1761c; quit;

data _null_; if 0 then set f1761o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1761 rows=' rows;
else do; set f1761o; if not missing(actual) and abs(actual-(4.5))<=1e-9*max(1,abs(4.5)) then put 'ROUND4_PASS=F1761';
else put 'ERROR: ROUND4_FAIL=F1761 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1761:; quit;
