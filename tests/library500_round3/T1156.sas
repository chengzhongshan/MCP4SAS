/* T1156 comma_format_roundtrip, N=7; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:198 */

data t1156o; length text $20; value=1001*7; text=put(value,comma20.); actual=input(text,comma20.); run;

data _null_; if 0 then set t1156o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1156 rows=' rows;
else do; set t1156o; if not missing(actual) and abs(actual-(7007))<=1e-10*max(1,abs(7007)) then put 'ROUND3_PASS=T1156';
else put 'ERROR: ROUND3_FAIL=T1156 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1156:; quit;
