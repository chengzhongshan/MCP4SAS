/* F1763 glm_cell_means, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1763a; do grp=1 to 2; do x=1 to 4; y=grp*x; output; end; end; run;
proc glm data=f1763a noprint; class grp; model y=grp; output out=f1763b p=predicted; quit;
proc sql; create table f1763c as select grp,mean(predicted) as pred from f1763b group by grp;
create table f1763o as select sum(pred) as actual from f1763c; quit;

data _null_; if 0 then set f1763o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1763 rows=' rows;
else do; set f1763o; if not missing(actual) and abs(actual-(7.5))<=1e-9*max(1,abs(7.5)) then put 'ROUND4_PASS=F1763';
else put 'ERROR: ROUND4_FAIL=F1763 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1763:; quit;
