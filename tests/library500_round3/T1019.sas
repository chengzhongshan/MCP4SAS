/* T1019 contents_character_length, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1019a; length text $10; text='a'; run;
proc contents data=t1019a out=t1019b noprint; run;
data t1019o; set t1019b; actual=length; run;

data _null_; if 0 then set t1019o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1019 rows=' rows;
else do; set t1019o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1019';
else put 'ERROR: ROUND3_FAIL=T1019 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1019:; quit;
