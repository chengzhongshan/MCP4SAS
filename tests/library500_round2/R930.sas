/* R930 input_ampersand, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:19 */

data r930o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  11
;
run;

data _null_; if 0 then set r930o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R930 rows=' rows;
else do; set r930o; if not missing(actual) and abs(actual-(111))<=1e-10*max(1,abs(111)) then put 'ROUND2_PASS=R930';
else put 'ERROR: ROUND2_FAIL=R930 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r930:; quit;
