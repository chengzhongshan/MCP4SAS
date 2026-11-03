/* F1764 glm_cell_means, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/add quit to restore ods output before using ods select none in proc glm.sas:4 */

data f1764a; do grp=1 to 2; do x=1 to 5; y=grp*x; output; end; end; run;
proc glm data=f1764a noprint; class grp; model y=grp; output out=f1764b p=predicted; quit;
proc sql; create table f1764c as select grp,mean(predicted) as pred from f1764b group by grp;
create table f1764o as select sum(pred) as actual from f1764c; quit;

data _null_; if 0 then set f1764o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1764 rows=' rows;
else do; set f1764o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND4_PASS=F1764';
else put 'ERROR: ROUND4_FAIL=F1764 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1764:; quit;
