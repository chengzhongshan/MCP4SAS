/* H2721 compress_control_whitespace, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2721o; length raw clean $60; raw=' A '||'09'x||'2'||'0A'x||' '; clean=compress(raw,,'s'); actual=2*(clean='A2'); run;

data _null_; if 0 then set h2721o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2721 rows=' rows;
else do; set h2721o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND6_PASS=H2721';
else put 'ERROR: ROUND6_FAIL=H2721 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2721:; quit;
