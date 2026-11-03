/* H2891 csv_import_quoted_delimiter, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

filename rtemp temp;
data _null_; file rtemp; put 'x,label'; do x=1 to 2; put x ',"a,b"'; end; run;
proc import datafile=rtemp out=h2891a dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2891o as select sum(x)+sum(label='a,b') as actual from h2891a; quit;

data _null_; if 0 then set h2891o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2891 rows=' rows;
else do; set h2891o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2891';
else put 'ERROR: ROUND6_FAIL=H2891 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2891:; quit;
