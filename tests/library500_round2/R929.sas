/* R929 input_ampersand, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:19 */

data r929o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  10
;
run;

data _null_; if 0 then set r929o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R929 rows=' rows;
else do; set r929o; if not missing(actual) and abs(actual-(110))<=1e-10*max(1,abs(110)) then put 'ROUND2_PASS=R929';
else put 'ERROR: ROUND2_FAIL=R929 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r929:; quit;
