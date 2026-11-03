/* T1018 contents_character_length, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1018a; length text $9; text='a'; run;
proc contents data=t1018a out=t1018b noprint; run;
data t1018o; set t1018b; actual=length; run;

data _null_; if 0 then set t1018o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1018 rows=' rows;
else do; set t1018o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1018';
else put 'ERROR: ROUND3_FAIL=T1018 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1018:; quit;
