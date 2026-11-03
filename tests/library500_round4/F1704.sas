/* F1704 corr_covariance, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1704a; do x=1 to 5; y=3*x; output; end; run;
proc corr data=f1704a outp=f1704b cov noprint; var x y; run;
data f1704o; set f1704b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1704o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1704 rows=' rows;
else do; set f1704o; if not missing(actual) and abs(actual-(7.5))<=1e-9*max(1,abs(7.5)) then put 'ROUND4_PASS=F1704';
else put 'ERROR: ROUND4_FAIL=F1704 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1704:; quit;
