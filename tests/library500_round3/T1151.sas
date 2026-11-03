/* T1151 comma_format_roundtrip, N=2; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:198 */

data t1151o; length text $20; value=1001*2; text=put(value,comma20.); actual=input(text,comma20.); run;

data _null_; if 0 then set t1151o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1151 rows=' rows;
else do; set t1151o; if not missing(actual) and abs(actual-(2002))<=1e-10*max(1,abs(2002)) then put 'ROUND3_PASS=T1151';
else put 'ERROR: ROUND3_FAIL=T1151 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1151:; quit;
