/* H2720 compress_keep_digits, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2720o; actual=input(compress('ab11cd',,'kd'),best32.); run;

data _null_; if 0 then set h2720o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2720 rows=' rows;
else do; set h2720o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2720';
else put 'ERROR: ROUND6_FAIL=H2720 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2720:; quit;
