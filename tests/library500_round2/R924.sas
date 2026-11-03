/* R924 input_ampersand, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:19 */

data r924o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  5
;
run;

data _null_; if 0 then set r924o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R924 rows=' rows;
else do; set r924o; if not missing(actual) and abs(actual-(105))<=1e-10*max(1,abs(105)) then put 'ROUND2_PASS=R924';
else put 'ERROR: ROUND2_FAIL=R924 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r924:; quit;
