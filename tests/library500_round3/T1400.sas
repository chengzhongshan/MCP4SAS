/* T1400 unquote_releases_nrstr, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/concatenate single quote with text of a macro variable.sas:8 */

%macro t1400m(); %eval(3*11) %mend;
%let t1400value=%unquote(%nrstr(%t1400m()));
data t1400o; actual=input(symget('t1400value'),best32.); run;
%symdel t1400value; %sysmacdelete t1400m;

data _null_; if 0 then set t1400o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1400 rows=' rows;
else do; set t1400o; if not missing(actual) and abs(actual-(33))<=1e-10*max(1,abs(33)) then put 'ROUND3_PASS=T1400';
else put 'ERROR: ROUND3_FAIL=T1400 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1400:; quit;
