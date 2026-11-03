/* H2895 csv_import_quoted_delimiter, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc IMPORT with guessingrows for VERY LARGE DATA FILE GE 1G.sas:9 */

filename rtemp temp;
data _null_; file rtemp; put 'x,label'; do x=1 to 6; put x ',"a,b"'; end; run;
proc import datafile=rtemp out=h2895a dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table h2895o as select sum(x)+sum(label='a,b') as actual from h2895a; quit;

data _null_; if 0 then set h2895o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2895 rows=' rows;
else do; set h2895o; if not missing(actual) and abs(actual-(27))<=1e-9*max(1,abs(27)) then put 'ROUND6_PASS=H2895';
else put 'ERROR: ROUND6_FAIL=H2895 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2895:; quit;
