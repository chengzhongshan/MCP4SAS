/* H2724 compress_control_whitespace, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2724o; length raw clean $60; raw=' A '||'09'x||'5'||'0A'x||' '; clean=compress(raw,,'s'); actual=5*(clean='A5'); run;

data _null_; if 0 then set h2724o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2724 rows=' rows;
else do; set h2724o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2724';
else put 'ERROR: ROUND6_FAIL=H2724 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2724:; quit;
