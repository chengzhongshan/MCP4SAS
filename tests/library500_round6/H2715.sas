/* H2715 compress_keep_digits, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2715o; actual=input(compress('ab6cd',,'kd'),best32.); run;

data _null_; if 0 then set h2715o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2715 rows=' rows;
else do; set h2715o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2715';
else put 'ERROR: ROUND6_FAIL=H2715 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2715:; quit;
