/* T1020 contents_character_length, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1020a; length text $11; text='a'; run;
proc contents data=t1020a out=t1020b noprint; run;
data t1020o; set t1020b; actual=length; run;

data _null_; if 0 then set t1020o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1020 rows=' rows;
else do; set t1020o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1020';
else put 'ERROR: ROUND3_FAIL=T1020 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1020:; quit;
