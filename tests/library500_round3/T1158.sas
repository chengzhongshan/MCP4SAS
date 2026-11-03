/* T1158 comma_format_roundtrip, N=9; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:198 */

data t1158o; length text $20; value=1001*9; text=put(value,comma20.); actual=input(text,comma20.); run;

data _null_; if 0 then set t1158o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1158 rows=' rows;
else do; set t1158o; if not missing(actual) and abs(actual-(9009))<=1e-10*max(1,abs(9009)) then put 'ROUND3_PASS=T1158';
else put 'ERROR: ROUND3_FAIL=T1158 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1158:; quit;
