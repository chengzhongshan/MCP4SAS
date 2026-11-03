/* R883 truncover_short_record, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas:17 */

filename rtemp temp;
data _null_; file rtemp; put '4'; run;
data r883o; infile rtemp truncover; input a 1-2 b 4-6; actual=a+100*missing(b); run;
filename rtemp clear;

data _null_; if 0 then set r883o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R883 rows=' rows;
else do; set r883o; if not missing(actual) and abs(actual-(104))<=1e-10*max(1,abs(104)) then put 'ROUND2_PASS=R883';
else put 'ERROR: ROUND2_FAIL=R883 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r883:; quit;
