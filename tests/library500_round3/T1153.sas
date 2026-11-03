/* T1153 comma_format_roundtrip, N=4; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:198 */

data t1153o; length text $20; value=1001*4; text=put(value,comma20.); actual=input(text,comma20.); run;

data _null_; if 0 then set t1153o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1153 rows=' rows;
else do; set t1153o; if not missing(actual) and abs(actual-(4004))<=1e-10*max(1,abs(4004)) then put 'ROUND3_PASS=T1153';
else put 'ERROR: ROUND3_FAIL=T1153 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1153:; quit;
