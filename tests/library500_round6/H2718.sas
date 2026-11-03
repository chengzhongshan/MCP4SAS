/* H2718 compress_keep_digits, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2718o; actual=input(compress('ab9cd',,'kd'),best32.); run;

data _null_; if 0 then set h2718o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2718 rows=' rows;
else do; set h2718o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2718';
else put 'ERROR: ROUND6_FAIL=H2718 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2718:; quit;
