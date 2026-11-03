/* G2304 single_at_conditional_input, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

filename rtemp temp;
data _null_; file rtemp; put 'skip junk'; put 'keep 5'; put 'keep 6'; run;
data g2304a; infile rtemp; input key $ @; if key='keep' then input value; else delete; run;
filename rtemp clear;
proc sql; create table g2304o as select sum(value) as actual from g2304a; quit;

data _null_; if 0 then set g2304o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2304 rows=' rows;
else do; set g2304o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2304';
else put 'ERROR: ROUND5_FAIL=G2304 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2304:; quit;
