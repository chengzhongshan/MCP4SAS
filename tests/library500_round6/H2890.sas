/* H2890 csv_export_import, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

data h2890a; do x=1 to 11; output; end; run;
filename rtemp temp;
proc export data=h2890a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=h2890b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2890o as select sum(x) as actual from h2890b; quit;

data _null_; if 0 then set h2890o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2890 rows=' rows;
else do; set h2890o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND6_PASS=H2890';
else put 'ERROR: ROUND6_FAIL=H2890 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2890:; quit;
