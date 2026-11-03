/* R923 input_ampersand, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:19 */

data r923o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  4
;
run;

data _null_; if 0 then set r923o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R923 rows=' rows;
else do; set r923o; if not missing(actual) and abs(actual-(104))<=1e-10*max(1,abs(104)) then put 'ROUND2_PASS=R923';
else put 'ERROR: ROUND2_FAIL=R923 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r923:; quit;
