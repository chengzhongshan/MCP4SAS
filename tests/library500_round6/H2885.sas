/* H2885 csv_export_import, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

data h2885a; do x=1 to 6; output; end; run;
filename rtemp temp;
proc export data=h2885a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=h2885b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2885o as select sum(x) as actual from h2885b; quit;

data _null_; if 0 then set h2885o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2885 rows=' rows;
else do; set h2885o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND6_PASS=H2885';
else put 'ERROR: ROUND6_FAIL=H2885 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2885:; quit;
