/* H2883 csv_export_import, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

data h2883a; do x=1 to 4; output; end; run;
filename rtemp temp;
proc export data=h2883a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=h2883b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2883o as select sum(x) as actual from h2883b; quit;

data _null_; if 0 then set h2883o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2883 rows=' rows;
else do; set h2883o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2883';
else put 'ERROR: ROUND6_FAIL=H2883 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2883:; quit;
