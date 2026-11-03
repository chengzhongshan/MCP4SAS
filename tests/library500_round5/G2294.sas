/* G2294 named_input_values, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

data g2294o; input a= b=; actual=a+b; datalines;
a=5 b=6
;
run;

data _null_; if 0 then set g2294o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2294 rows=' rows;
else do; set g2294o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2294';
else put 'ERROR: ROUND5_FAIL=G2294 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2294:; quit;
