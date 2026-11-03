/* H2722 compress_control_whitespace, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2722o; length raw clean $60; raw=' A '||'09'x||'3'||'0A'x||' '; clean=compress(raw,,'s'); actual=3*(clean='A3'); run;

data _null_; if 0 then set h2722o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2722 rows=' rows;
else do; set h2722o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2722';
else put 'ERROR: ROUND6_FAIL=H2722 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2722:; quit;
