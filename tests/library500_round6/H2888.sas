/* H2888 csv_export_import, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

data h2888a; do x=1 to 9; output; end; run;
filename rtemp temp;
proc export data=h2888a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=h2888b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2888o as select sum(x) as actual from h2888b; quit;

data _null_; if 0 then set h2888o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2888 rows=' rows;
else do; set h2888o; if not missing(actual) and abs(actual-(45))<=1e-9*max(1,abs(45)) then put 'ROUND6_PASS=H2888';
else put 'ERROR: ROUND6_FAIL=H2888 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2888:; quit;
