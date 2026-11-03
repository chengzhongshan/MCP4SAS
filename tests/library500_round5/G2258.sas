/* G2258 tab_delimited_input, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:12 */

filename rtemp temp;
data _null_; file rtemp; put 'alpha' '09'x '9'; run;
data g2258o; infile rtemp dlm='09'x dsd; input label :$20. actual; run;
filename rtemp clear;

data _null_; if 0 then set g2258o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2258 rows=' rows;
else do; set g2258o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2258';
else put 'ERROR: ROUND5_FAIL=G2258 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2258:; quit;
