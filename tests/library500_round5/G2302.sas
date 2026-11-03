/* G2302 single_at_conditional_input, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

filename rtemp temp;
data _null_; file rtemp; put 'skip junk'; put 'keep 3'; put 'keep 4'; run;
data g2302a; infile rtemp; input key $ @; if key='keep' then input value; else delete; run;
filename rtemp clear;
proc sql; create table g2302o as select sum(value) as actual from g2302a; quit;

data _null_; if 0 then set g2302o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2302 rows=' rows;
else do; set g2302o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2302';
else put 'ERROR: ROUND5_FAIL=G2302 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2302:; quit;
