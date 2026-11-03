/* G2296 named_input_values, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

data g2296o; input a= b=; actual=a+b; datalines;
a=7 b=8
;
run;

data _null_; if 0 then set g2296o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2296 rows=' rows;
else do; set g2296o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND5_PASS=G2296';
else put 'ERROR: ROUND5_FAIL=G2296 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2296:; quit;
