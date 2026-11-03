/* T1397 unquote_releases_nrstr, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/concatenate single quote with text of a macro variable.sas:8 */

%macro t1397m(); %eval(3*8) %mend;
%let t1397value=%unquote(%nrstr(%t1397m()));
data t1397o; actual=input(symget('t1397value'),best32.); run;
%symdel t1397value; %sysmacdelete t1397m;

data _null_; if 0 then set t1397o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1397 rows=' rows;
else do; set t1397o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND3_PASS=T1397';
else put 'ERROR: ROUND3_FAIL=T1397 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1397:; quit;
