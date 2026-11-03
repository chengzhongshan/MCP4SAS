/* H2723 compress_control_whitespace, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2723o; length raw clean $60; raw=' A '||'09'x||'4'||'0A'x||' '; clean=compress(raw,,'s'); actual=4*(clean='A4'); run;

data _null_; if 0 then set h2723o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2723 rows=' rows;
else do; set h2723o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2723';
else put 'ERROR: ROUND6_FAIL=H2723 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2723:; quit;
