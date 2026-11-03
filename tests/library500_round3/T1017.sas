/* T1017 contents_character_length, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1017a; length text $8; text='a'; run;
proc contents data=t1017a out=t1017b noprint; run;
data t1017o; set t1017b; actual=length; run;

data _null_; if 0 then set t1017o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1017 rows=' rows;
else do; set t1017o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1017';
else put 'ERROR: ROUND3_FAIL=T1017 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1017:; quit;
