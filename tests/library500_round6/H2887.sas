/* H2887 csv_export_import, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

data h2887a; do x=1 to 8; output; end; run;
filename rtemp temp;
proc export data=h2887a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=h2887b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2887o as select sum(x) as actual from h2887b; quit;

data _null_; if 0 then set h2887o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2887 rows=' rows;
else do; set h2887o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND6_PASS=H2887';
else put 'ERROR: ROUND6_FAIL=H2887 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2887:; quit;
