/* G2300 named_input_values, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

data g2300o; input a= b=; actual=a+b; datalines;
a=11 b=12
;
run;

data _null_; if 0 then set g2300o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2300 rows=' rows;
else do; set g2300o; if not missing(actual) and abs(actual-(23))<=1e-9*max(1,abs(23)) then put 'ROUND5_PASS=G2300';
else put 'ERROR: ROUND5_FAIL=G2300 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2300:; quit;
