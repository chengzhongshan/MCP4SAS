/* R887 truncover_short_record, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:17 */

filename rtemp temp;
data _null_; file rtemp; put '8'; run;
data r887o; infile rtemp truncover; input a 1-2 b 4-6; actual=a+100*missing(b); run;
filename rtemp clear;

data _null_; if 0 then set r887o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R887 rows=' rows;
else do; set r887o; if not missing(actual) and abs(actual-(108))<=1e-10*max(1,abs(108)) then put 'ROUND2_PASS=R887';
else put 'ERROR: ROUND2_FAIL=R887 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r887:; quit;
