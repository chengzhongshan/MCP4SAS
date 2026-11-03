/* H2714 compress_keep_digits, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2714o; actual=input(compress('ab5cd',,'kd'),best32.); run;

data _null_; if 0 then set h2714o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2714 rows=' rows;
else do; set h2714o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2714';
else put 'ERROR: ROUND6_FAIL=H2714 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2714:; quit;
