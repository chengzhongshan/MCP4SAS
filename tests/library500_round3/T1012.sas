/* T1012 contents_character_length, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1012a; length text $3; text='a'; run;
proc contents data=t1012a out=t1012b noprint; run;
data t1012o; set t1012b; actual=length; run;

data _null_; if 0 then set t1012o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1012 rows=' rows;
else do; set t1012o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1012';
else put 'ERROR: ROUND3_FAIL=T1012 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1012:; quit;
