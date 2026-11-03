/* T1392 unquote_releases_nrstr, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/concatenate single quote with text of a macro variable.sas:8 */

%macro t1392m(); %eval(3*3) %mend;
%let t1392value=%unquote(%nrstr(%t1392m()));
data t1392o; actual=input(symget('t1392value'),best32.); run;
%symdel t1392value; %sysmacdelete t1392m;

data _null_; if 0 then set t1392o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1392 rows=' rows;
else do; set t1392o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1392';
else put 'ERROR: ROUND3_FAIL=T1392 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1392:; quit;
