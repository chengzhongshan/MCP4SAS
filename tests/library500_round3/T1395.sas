/* T1395 unquote_releases_nrstr, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/concatenate single quote with text of a macro variable.sas:8 */

%macro t1395m(); %eval(3*6) %mend;
%let t1395value=%unquote(%nrstr(%t1395m()));
data t1395o; actual=input(symget('t1395value'),best32.); run;
%symdel t1395value; %sysmacdelete t1395m;

data _null_; if 0 then set t1395o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1395 rows=' rows;
else do; set t1395o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND3_PASS=T1395';
else put 'ERROR: ROUND3_FAIL=T1395 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1395:; quit;
