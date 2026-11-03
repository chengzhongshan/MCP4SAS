/* H2716 compress_keep_digits, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2716o; actual=input(compress('ab7cd',,'kd'),best32.); run;

data _null_; if 0 then set h2716o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2716 rows=' rows;
else do; set h2716o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2716';
else put 'ERROR: ROUND6_FAIL=H2716 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2716:; quit;
