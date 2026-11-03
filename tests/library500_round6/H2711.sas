/* H2711 compress_keep_digits, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2711o; actual=input(compress('ab2cd',,'kd'),best32.); run;

data _null_; if 0 then set h2711o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2711 rows=' rows;
else do; set h2711o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND6_PASS=H2711';
else put 'ERROR: ROUND6_FAIL=H2711 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2711:; quit;
