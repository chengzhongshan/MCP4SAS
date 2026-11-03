/* H2886 csv_export_import, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

data h2886a; do x=1 to 7; output; end; run;
filename rtemp temp;
proc export data=h2886a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=h2886b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2886o as select sum(x) as actual from h2886b; quit;

data _null_; if 0 then set h2886o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2886 rows=' rows;
else do; set h2886o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND6_PASS=H2886';
else put 'ERROR: ROUND6_FAIL=H2886 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2886:; quit;
