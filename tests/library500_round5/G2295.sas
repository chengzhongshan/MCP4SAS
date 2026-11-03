/* G2295 named_input_values, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

data g2295o; input a= b=; actual=a+b; datalines;
a=6 b=7
;
run;

data _null_; if 0 then set g2295o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2295 rows=' rows;
else do; set g2295o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND5_PASS=G2295';
else put 'ERROR: ROUND5_FAIL=G2295 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2295:; quit;
