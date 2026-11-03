/* F1705 corr_covariance, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1705a; do x=1 to 6; y=3*x; output; end; run;
proc corr data=f1705a outp=f1705b cov noprint; var x y; run;
data f1705o; set f1705b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1705o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1705 rows=' rows;
else do; set f1705o; if not missing(actual) and abs(actual-(10.5))<=1e-9*max(1,abs(10.5)) then put 'ROUND4_PASS=F1705';
else put 'ERROR: ROUND4_FAIL=F1705 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1705:; quit;
