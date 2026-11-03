/* G2305 single_at_conditional_input, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

filename rtemp temp;
data _null_; file rtemp; put 'skip junk'; put 'keep 6'; put 'keep 7'; run;
data g2305a; infile rtemp; input key $ @; if key='keep' then input value; else delete; run;
filename rtemp clear;
proc sql; create table g2305o as select sum(value) as actual from g2305a; quit;

data _null_; if 0 then set g2305o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2305 rows=' rows;
else do; set g2305o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND5_PASS=G2305';
else put 'ERROR: ROUND5_FAIL=G2305 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2305:; quit;
