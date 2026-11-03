/* F1798 freq_uniform_percent, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1798a; do k=1 to 9; output; end; run;
proc freq data=f1798a noprint; tables k / out=f1798b; run;
proc sql; create table f1798o as select max(percent) as actual from f1798b; quit;

data _null_; if 0 then set f1798o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1798 rows=' rows;
else do; set f1798o; if not missing(actual) and abs(actual-(11.1111111111111))<=1e-9*max(1,abs(11.1111111111111)) then put 'ROUND4_PASS=F1798';
else put 'ERROR: ROUND4_FAIL=F1798 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1798:; quit;
