/* G2303 single_at_conditional_input, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

filename rtemp temp;
data _null_; file rtemp; put 'skip junk'; put 'keep 4'; put 'keep 5'; run;
data g2303a; infile rtemp; input key $ @; if key='keep' then input value; else delete; run;
filename rtemp clear;
proc sql; create table g2303o as select sum(value) as actual from g2303a; quit;

data _null_; if 0 then set g2303o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2303 rows=' rows;
else do; set g2303o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2303';
else put 'ERROR: ROUND5_FAIL=G2303 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2303:; quit;
