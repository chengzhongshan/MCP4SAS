/* G2292 named_input_values, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

data g2292o; input a= b=; actual=a+b; datalines;
a=3 b=4
;
run;

data _null_; if 0 then set g2292o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2292 rows=' rows;
else do; set g2292o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2292';
else put 'ERROR: ROUND5_FAIL=G2292 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2292:; quit;
