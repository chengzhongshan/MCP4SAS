/* R926 input_ampersand, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:19 */

data r926o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  7
;
run;

data _null_; if 0 then set r926o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R926 rows=' rows;
else do; set r926o; if not missing(actual) and abs(actual-(107))<=1e-10*max(1,abs(107)) then put 'ROUND2_PASS=R926';
else put 'ERROR: ROUND2_FAIL=R926 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r926:; quit;
