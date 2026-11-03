/* H2717 compress_keep_digits, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2717o; actual=input(compress('ab8cd',,'kd'),best32.); run;

data _null_; if 0 then set h2717o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2717 rows=' rows;
else do; set h2717o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2717';
else put 'ERROR: ROUND6_FAIL=H2717 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2717:; quit;
