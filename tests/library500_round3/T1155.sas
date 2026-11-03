/* T1155 comma_format_roundtrip, N=6; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:198 */

data t1155o; length text $20; value=1001*6; text=put(value,comma20.); actual=input(text,comma20.); run;

data _null_; if 0 then set t1155o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1155 rows=' rows;
else do; set t1155o; if not missing(actual) and abs(actual-(6006))<=1e-10*max(1,abs(6006)) then put 'ROUND3_PASS=T1155';
else put 'ERROR: ROUND3_FAIL=T1155 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1155:; quit;
