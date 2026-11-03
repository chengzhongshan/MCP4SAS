/* H2730 compress_control_whitespace, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2730o; length raw clean $60; raw=' A '||'09'x||'11'||'0A'x||' '; clean=compress(raw,,'s'); actual=11*(clean='A11'); run;

data _null_; if 0 then set h2730o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2730 rows=' rows;
else do; set h2730o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2730';
else put 'ERROR: ROUND6_FAIL=H2730 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2730:; quit;
