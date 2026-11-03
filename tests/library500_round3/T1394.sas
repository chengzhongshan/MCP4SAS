/* T1394 unquote_releases_nrstr, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/concatenate single quote with text of a macro variable.sas:8 */

%macro t1394m(); %eval(3*5) %mend;
%let t1394value=%unquote(%nrstr(%t1394m()));
data t1394o; actual=input(symget('t1394value'),best32.); run;
%symdel t1394value; %sysmacdelete t1394m;

data _null_; if 0 then set t1394o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1394 rows=' rows;
else do; set t1394o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1394';
else put 'ERROR: ROUND3_FAIL=T1394 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1394:; quit;
