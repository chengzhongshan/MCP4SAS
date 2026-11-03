/* H2725 compress_control_whitespace, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2725o; length raw clean $60; raw=' A '||'09'x||'6'||'0A'x||' '; clean=compress(raw,,'s'); actual=6*(clean='A6'); run;

data _null_; if 0 then set h2725o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2725 rows=' rows;
else do; set h2725o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2725';
else put 'ERROR: ROUND6_FAIL=H2725 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2725:; quit;
