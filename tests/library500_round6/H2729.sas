/* H2729 compress_control_whitespace, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2729o; length raw clean $60; raw=' A '||'09'x||'10'||'0A'x||' '; clean=compress(raw,,'s'); actual=10*(clean='A10'); run;

data _null_; if 0 then set h2729o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2729 rows=' rows;
else do; set h2729o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2729';
else put 'ERROR: ROUND6_FAIL=H2729 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2729:; quit;
