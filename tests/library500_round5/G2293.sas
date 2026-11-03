/* G2293 named_input_values, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

data g2293o; input a= b=; actual=a+b; datalines;
a=4 b=5
;
run;

data _null_; if 0 then set g2293o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2293 rows=' rows;
else do; set g2293o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2293';
else put 'ERROR: ROUND5_FAIL=G2293 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2293:; quit;
