/* T1152 comma_format_roundtrip, N=3; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:198 */

data t1152o; length text $20; value=1001*3; text=put(value,comma20.); actual=input(text,comma20.); run;

data _null_; if 0 then set t1152o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1152 rows=' rows;
else do; set t1152o; if not missing(actual) and abs(actual-(3003))<=1e-10*max(1,abs(3003)) then put 'ROUND3_PASS=T1152';
else put 'ERROR: ROUND3_FAIL=T1152 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1152:; quit;
