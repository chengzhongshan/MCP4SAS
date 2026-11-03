/* T1015 contents_character_length, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1015a; length text $6; text='a'; run;
proc contents data=t1015a out=t1015b noprint; run;
data t1015o; set t1015b; actual=length; run;

data _null_; if 0 then set t1015o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1015 rows=' rows;
else do; set t1015o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1015';
else put 'ERROR: ROUND3_FAIL=T1015 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1015:; quit;
