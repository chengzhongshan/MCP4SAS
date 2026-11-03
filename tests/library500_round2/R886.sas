/* R886 truncover_short_record, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:17 */

filename rtemp temp;
data _null_; file rtemp; put '7'; run;
data r886o; infile rtemp truncover; input a 1-2 b 4-6; actual=a+100*missing(b); run;
filename rtemp clear;

data _null_; if 0 then set r886o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R886 rows=' rows;
else do; set r886o; if not missing(actual) and abs(actual-(107))<=1e-10*max(1,abs(107)) then put 'ROUND2_PASS=R886';
else put 'ERROR: ROUND2_FAIL=R886 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r886:; quit;
