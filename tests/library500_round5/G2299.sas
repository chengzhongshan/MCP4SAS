/* G2299 named_input_values, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

data g2299o; input a= b=; actual=a+b; datalines;
a=10 b=11
;
run;

data _null_; if 0 then set g2299o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2299 rows=' rows;
else do; set g2299o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND5_PASS=G2299';
else put 'ERROR: ROUND5_FAIL=G2299 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2299:; quit;
