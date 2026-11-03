/* G2297 named_input_values, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

data g2297o; input a= b=; actual=a+b; datalines;
a=8 b=9
;
run;

data _null_; if 0 then set g2297o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2297 rows=' rows;
else do; set g2297o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND5_PASS=G2297';
else put 'ERROR: ROUND5_FAIL=G2297 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2297:; quit;
