/* T1016 contents_character_length, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/different usage of avg and mean in proc sql.sas:31 */

data t1016a; length text $7; text='a'; run;
proc contents data=t1016a out=t1016b noprint; run;
data t1016o; set t1016b; actual=length; run;

data _null_; if 0 then set t1016o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1016 rows=' rows;
else do; set t1016o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1016';
else put 'ERROR: ROUND3_FAIL=T1016 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1016:; quit;
