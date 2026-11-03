/* T1391 unquote_releases_nrstr, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/concatenate single quote with text of a macro variable.sas:8 */

%macro t1391m(); %eval(3*2) %mend;
%let t1391value=%unquote(%nrstr(%t1391m()));
data t1391o; actual=input(symget('t1391value'),best32.); run;
%symdel t1391value; %sysmacdelete t1391m;

data _null_; if 0 then set t1391o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1391 rows=' rows;
else do; set t1391o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1391';
else put 'ERROR: ROUND3_FAIL=T1391 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1391:; quit;
