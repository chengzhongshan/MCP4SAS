/* R881 truncover_short_record, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:17 */

filename rtemp temp;
data _null_; file rtemp; put '2'; run;
data r881o; infile rtemp truncover; input a 1-2 b 4-6; actual=a+100*missing(b); run;
filename rtemp clear;

data _null_; if 0 then set r881o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R881 rows=' rows;
else do; set r881o; if not missing(actual) and abs(actual-(102))<=1e-10*max(1,abs(102)) then put 'ROUND2_PASS=R881';
else put 'ERROR: ROUND2_FAIL=R881 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r881:; quit;
