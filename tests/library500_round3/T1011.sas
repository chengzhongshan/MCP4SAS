/* T1011 contents_character_length, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1011a; length text $2; text='a'; run;
proc contents data=t1011a out=t1011b noprint; run;
data t1011o; set t1011b; actual=length; run;

data _null_; if 0 then set t1011o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1011 rows=' rows;
else do; set t1011o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1011';
else put 'ERROR: ROUND3_FAIL=T1011 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1011:; quit;
