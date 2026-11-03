/* H2719 compress_keep_digits, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2719o; actual=input(compress('ab10cd',,'kd'),best32.); run;

data _null_; if 0 then set h2719o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2719 rows=' rows;
else do; set h2719o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2719';
else put 'ERROR: ROUND6_FAIL=H2719 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2719:; quit;
