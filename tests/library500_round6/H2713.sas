/* H2713 compress_keep_digits, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2713o; actual=input(compress('ab4cd',,'kd'),best32.); run;

data _null_; if 0 then set h2713o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2713 rows=' rows;
else do; set h2713o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2713';
else put 'ERROR: ROUND6_FAIL=H2713 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2713:; quit;
