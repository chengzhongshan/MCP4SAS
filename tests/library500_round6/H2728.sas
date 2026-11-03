/* H2728 compress_control_whitespace, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2728o; length raw clean $60; raw=' A '||'09'x||'9'||'0A'x||' '; clean=compress(raw,,'s'); actual=9*(clean='A9'); run;

data _null_; if 0 then set h2728o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2728 rows=' rows;
else do; set h2728o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2728';
else put 'ERROR: ROUND6_FAIL=H2728 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2728:; quit;
