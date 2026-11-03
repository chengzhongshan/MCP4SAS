/* T1399 unquote_releases_nrstr, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/concatenate single quote with text of a macro variable.sas:8 */

%macro t1399m(); %eval(3*10) %mend;
%let t1399value=%unquote(%nrstr(%t1399m()));
data t1399o; actual=input(symget('t1399value'),best32.); run;
%symdel t1399value; %sysmacdelete t1399m;

data _null_; if 0 then set t1399o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1399 rows=' rows;
else do; set t1399o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND3_PASS=T1399';
else put 'ERROR: ROUND3_FAIL=T1399 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1399:; quit;
