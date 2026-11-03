/* H2893 csv_import_quoted_delimiter, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

filename rtemp temp;
data _null_; file rtemp; put 'x,label'; do x=1 to 4; put x ',"a,b"'; end; run;
proc import datafile=rtemp out=h2893a dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2893o as select sum(x)+sum(label='a,b') as actual from h2893a; quit;

data _null_; if 0 then set h2893o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2893 rows=' rows;
else do; set h2893o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND6_PASS=H2893';
else put 'ERROR: ROUND6_FAIL=H2893 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2893:; quit;
