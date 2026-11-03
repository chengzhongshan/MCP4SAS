/* T1393 unquote_releases_nrstr, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/concatenate single quote with text of a macro variable.sas:8 */

%macro t1393m(); %eval(3*4) %mend;
%let t1393value=%unquote(%nrstr(%t1393m()));
data t1393o; actual=input(symget('t1393value'),best32.); run;
%symdel t1393value; %sysmacdelete t1393m;

data _null_; if 0 then set t1393o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1393 rows=' rows;
else do; set t1393o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1393';
else put 'ERROR: ROUND3_FAIL=T1393 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1393:; quit;
