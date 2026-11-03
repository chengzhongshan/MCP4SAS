/* H2899 csv_import_quoted_delimiter, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

filename rtemp temp;
data _null_; file rtemp; put 'x,label'; do x=1 to 10; put x ',"a,b"'; end; run;
proc import datafile=rtemp out=h2899a dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2899o as select sum(x)+sum(label='a,b') as actual from h2899a; quit;

data _null_; if 0 then set h2899o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2899 rows=' rows;
else do; set h2899o; if not missing(actual) and abs(actual-(65))<=1e-9*max(1,abs(65)) then put 'ROUND6_PASS=H2899';
else put 'ERROR: ROUND6_FAIL=H2899 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2899:; quit;
