/* G2252 tab_delimited_input, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:12 */

filename rtemp temp;
data _null_; file rtemp; put 'alpha' '09'x '3'; run;
data g2252o; infile rtemp dlm='09'x dsd; input label :$20. actual; run;
filename rtemp clear;

data _null_; if 0 then set g2252o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2252 rows=' rows;
else do; set g2252o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2252';
else put 'ERROR: ROUND5_FAIL=G2252 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2252:; quit;
