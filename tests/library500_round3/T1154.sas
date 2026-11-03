/* T1154 comma_format_roundtrip, N=5; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:198 */

data t1154o; length text $20; value=1001*5; text=put(value,comma20.); actual=input(text,comma20.); run;

data _null_; if 0 then set t1154o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1154 rows=' rows;
else do; set t1154o; if not missing(actual) and abs(actual-(5005))<=1e-10*max(1,abs(5005)) then put 'ROUND3_PASS=T1154';
else put 'ERROR: ROUND3_FAIL=T1154 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1154:; quit;
