/* T1013 contents_character_length, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1013a; length text $4; text='a'; run;
proc contents data=t1013a out=t1013b noprint; run;
data t1013o; set t1013b; actual=length; run;

data _null_; if 0 then set t1013o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1013 rows=' rows;
else do; set t1013o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1013';
else put 'ERROR: ROUND3_FAIL=T1013 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1013:; quit;
