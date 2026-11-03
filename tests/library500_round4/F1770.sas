/* F1770 glm_cell_means, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1770a; do grp=1 to 2; do x=1 to 11; y=grp*x; output; end; end; run;
proc glm data=f1770a noprint; class grp; model y=grp; output out=f1770b p=predicted; quit;
proc sql; create table f1770c as select grp,mean(predicted) as pred from f1770b group by grp;
create table f1770o as select sum(pred) as actual from f1770c; quit;

data _null_; if 0 then set f1770o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1770 rows=' rows;
else do; set f1770o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND4_PASS=F1770';
else put 'ERROR: ROUND4_FAIL=F1770 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1770:; quit;
