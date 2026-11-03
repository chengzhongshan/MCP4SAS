/* T1157 comma_format_roundtrip, N=8; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:198 */

data t1157o; length text $20; value=1001*8; text=put(value,comma20.); actual=input(text,comma20.); run;

data _null_; if 0 then set t1157o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1157 rows=' rows;
else do; set t1157o; if not missing(actual) and abs(actual-(8008))<=1e-10*max(1,abs(8008)) then put 'ROUND3_PASS=T1157';
else put 'ERROR: ROUND3_FAIL=T1157 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1157:; quit;
