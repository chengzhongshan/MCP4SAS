/* H2727 compress_control_whitespace, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2727o; length raw clean $60; raw=' A '||'09'x||'8'||'0A'x||' '; clean=compress(raw,,'s'); actual=8*(clean='A8'); run;

data _null_; if 0 then set h2727o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2727 rows=' rows;
else do; set h2727o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2727';
else put 'ERROR: ROUND6_FAIL=H2727 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2727:; quit;
