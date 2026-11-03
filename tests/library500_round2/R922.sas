/* R922 input_ampersand, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:19 */

data r922o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  3
;
run;

data _null_; if 0 then set r922o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R922 rows=' rows;
else do; set r922o; if not missing(actual) and abs(actual-(103))<=1e-10*max(1,abs(103)) then put 'ROUND2_PASS=R922';
else put 'ERROR: ROUND2_FAIL=R922 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r922:; quit;
