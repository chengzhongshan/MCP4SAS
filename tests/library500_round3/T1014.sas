/* T1014 contents_character_length, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1014a; length text $5; text='a'; run;
proc contents data=t1014a out=t1014b noprint; run;
data t1014o; set t1014b; actual=length; run;

data _null_; if 0 then set t1014o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1014 rows=' rows;
else do; set t1014o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1014';
else put 'ERROR: ROUND3_FAIL=T1014 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1014:; quit;
