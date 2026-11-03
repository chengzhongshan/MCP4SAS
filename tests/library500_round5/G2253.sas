/* G2253 tab_delimited_input, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:12 */

filename rtemp temp;
data _null_; file rtemp; put 'alpha' '09'x '4'; run;
data g2253o; infile rtemp dlm='09'x dsd; input label :$20. actual; run;
filename rtemp clear;

data _null_; if 0 then set g2253o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2253 rows=' rows;
else do; set g2253o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2253';
else put 'ERROR: ROUND5_FAIL=G2253 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2253:; quit;
