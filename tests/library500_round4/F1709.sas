/* F1709 corr_covariance, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1709a; do x=1 to 10; y=3*x; output; end; run;
proc corr data=f1709a outp=f1709b cov noprint; var x y; run;
data f1709o; set f1709b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1709o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1709 rows=' rows;
else do; set f1709o; if not missing(actual) and abs(actual-(27.5))<=1e-9*max(1,abs(27.5)) then put 'ROUND4_PASS=F1709';
else put 'ERROR: ROUND4_FAIL=F1709 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1709:; quit;
