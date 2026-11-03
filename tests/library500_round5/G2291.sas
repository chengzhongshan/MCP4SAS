/* G2291 named_input_values, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

data g2291o; input a= b=; actual=a+b; datalines;
a=2 b=3
;
run;

data _null_; if 0 then set g2291o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2291 rows=' rows;
else do; set g2291o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2291';
else put 'ERROR: ROUND5_FAIL=G2291 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2291:; quit;
