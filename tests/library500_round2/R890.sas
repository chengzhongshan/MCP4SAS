/* R890 truncover_short_record, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:17 */

filename rtemp temp;
data _null_; file rtemp; put '11'; run;
data r890o; infile rtemp truncover; input a 1-2 b 4-6; actual=a+100*missing(b); run;
filename rtemp clear;

data _null_; if 0 then set r890o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R890 rows=' rows;
else do; set r890o; if not missing(actual) and abs(actual-(111))<=1e-10*max(1,abs(111)) then put 'ROUND2_PASS=R890';
else put 'ERROR: ROUND2_FAIL=R890 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r890:; quit;
