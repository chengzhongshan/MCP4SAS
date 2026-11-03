/* T1396 unquote_releases_nrstr, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/concatenate single quote with text of a macro variable.sas:8 */

%macro t1396m(); %eval(3*7) %mend;
%let t1396value=%unquote(%nrstr(%t1396m()));
data t1396o; actual=input(symget('t1396value'),best32.); run;
%symdel t1396value; %sysmacdelete t1396m;

data _null_; if 0 then set t1396o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1396 rows=' rows;
else do; set t1396o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND3_PASS=T1396';
else put 'ERROR: ROUND3_FAIL=T1396 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1396:; quit;
