/* R928 input_ampersand, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:19 */

data r928o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  9
;
run;

data _null_; if 0 then set r928o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R928 rows=' rows;
else do; set r928o; if not missing(actual) and abs(actual-(109))<=1e-10*max(1,abs(109)) then put 'ROUND2_PASS=R928';
else put 'ERROR: ROUND2_FAIL=R928 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r928:; quit;
