/* R927 input_ampersand, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:19 */

data r927o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  8
;
run;

data _null_; if 0 then set r927o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R927 rows=' rows;
else do; set r927o; if not missing(actual) and abs(actual-(108))<=1e-10*max(1,abs(108)) then put 'ROUND2_PASS=R927';
else put 'ERROR: ROUND2_FAIL=R927 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r927:; quit;
