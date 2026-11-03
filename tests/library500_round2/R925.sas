/* R925 input_ampersand, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:19 */

data r925o; input label & $20. value; actual=value+100*(label='New York'); datalines;
New York  6
;
run;

data _null_; if 0 then set r925o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R925 rows=' rows;
else do; set r925o; if not missing(actual) and abs(actual-(106))<=1e-10*max(1,abs(106)) then put 'ROUND2_PASS=R925';
else put 'ERROR: ROUND2_FAIL=R925 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r925:; quit;
