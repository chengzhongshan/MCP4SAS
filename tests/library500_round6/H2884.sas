/* H2884 csv_export_import, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

data h2884a; do x=1 to 5; output; end; run;
filename rtemp temp;
proc export data=h2884a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=h2884b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2884o as select sum(x) as actual from h2884b; quit;

data _null_; if 0 then set h2884o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2884 rows=' rows;
else do; set h2884o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND6_PASS=H2884';
else put 'ERROR: ROUND6_FAIL=H2884 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2884:; quit;
