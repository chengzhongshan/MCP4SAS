/* H2889 csv_export_import, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

data h2889a; do x=1 to 10; output; end; run;
filename rtemp temp;
proc export data=h2889a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=h2889b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2889o as select sum(x) as actual from h2889b; quit;

data _null_; if 0 then set h2889o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2889 rows=' rows;
else do; set h2889o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND6_PASS=H2889';
else put 'ERROR: ROUND6_FAIL=H2889 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2889:; quit;
