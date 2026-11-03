/* T1398 unquote_releases_nrstr, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/concatenate single quote with text of a macro variable.sas:8 */

%macro t1398m(); %eval(3*9) %mend;
%let t1398value=%unquote(%nrstr(%t1398m()));
data t1398o; actual=input(symget('t1398value'),best32.); run;
%symdel t1398value; %sysmacdelete t1398m;

data _null_; if 0 then set t1398o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1398 rows=' rows;
else do; set t1398o; if not missing(actual) and abs(actual-(27))<=1e-10*max(1,abs(27)) then put 'ROUND3_PASS=T1398';
else put 'ERROR: ROUND3_FAIL=T1398 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1398:; quit;
