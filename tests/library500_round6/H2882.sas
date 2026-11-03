/* H2882 csv_export_import, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

data h2882a; do x=1 to 3; output; end; run;
filename rtemp temp;
proc export data=h2882a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=h2882b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2882o as select sum(x) as actual from h2882b; quit;

data _null_; if 0 then set h2882o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2882 rows=' rows;
else do; set h2882o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2882';
else put 'ERROR: ROUND6_FAIL=H2882 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2882:; quit;
