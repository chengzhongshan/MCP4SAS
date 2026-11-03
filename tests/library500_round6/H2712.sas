/* H2712 compress_keep_digits, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */

data h2712o; actual=input(compress('ab3cd',,'kd'),best32.); run;

data _null_; if 0 then set h2712o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2712 rows=' rows;
else do; set h2712o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2712';
else put 'ERROR: ROUND6_FAIL=H2712 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2712:; quit;
