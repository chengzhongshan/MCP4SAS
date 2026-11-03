/* R921 input_ampersand, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:19 */

data r921o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  2
;
run;

data _null_; if 0 then set r921o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R921 rows=' rows;
else do; set r921o; if not missing(actual) and abs(actual-(102))<=1e-10*max(1,abs(102)) then put 'ROUND2_PASS=R921';
else put 'ERROR: ROUND2_FAIL=R921 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r921:; quit;
