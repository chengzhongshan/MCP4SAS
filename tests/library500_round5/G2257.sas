/* G2257 tab_delimited_input, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:12 */

filename rtemp temp;
data _null_; file rtemp; put 'alpha' '09'x '8'; run;
data g2257o; infile rtemp dlm='09'x dsd; input label :$20. actual; run;
filename rtemp clear;

data _null_; if 0 then set g2257o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2257 rows=' rows;
else do; set g2257o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2257';
else put 'ERROR: ROUND5_FAIL=G2257 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2257:; quit;
