/* H2881 csv_export_import, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

data h2881a; do x=1 to 2; output; end; run;
filename rtemp temp;
proc export data=h2881a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=h2881b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2881o as select sum(x) as actual from h2881b; quit;

data _null_; if 0 then set h2881o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2881 rows=' rows;
else do; set h2881o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2881';
else put 'ERROR: ROUND6_FAIL=H2881 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2881:; quit;
