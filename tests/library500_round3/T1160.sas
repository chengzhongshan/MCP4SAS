/* T1160 comma_format_roundtrip, N=11; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:198 */

data t1160o; length text $20; value=1001*11; text=put(value,comma20.); actual=input(text,comma20.); run;

data _null_; if 0 then set t1160o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1160 rows=' rows;
else do; set t1160o; if not missing(actual) and abs(actual-(11011))<=1e-10*max(1,abs(11011)) then put 'ROUND3_PASS=T1160';
else put 'ERROR: ROUND3_FAIL=T1160 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1160:; quit;
