/* H2726 compress_control_whitespace, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2726o; length raw clean $60; raw=' A '||'09'x||'7'||'0A'x||' '; clean=compress(raw,,'s'); actual=7*(clean='A7'); run;

data _null_; if 0 then set h2726o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2726 rows=' rows;
else do; set h2726o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2726';
else put 'ERROR: ROUND6_FAIL=H2726 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2726:; quit;
