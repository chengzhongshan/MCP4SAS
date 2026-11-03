/* G2301 single_at_conditional_input, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

filename rtemp temp;
data _null_; file rtemp; put 'skip junk'; put 'keep 2'; put 'keep 3'; run;
data g2301a; infile rtemp; input key $ @; if key='keep' then input value; else delete; run;
filename rtemp clear;
proc sql; create table g2301o as select sum(value) as actual from g2301a; quit;

data _null_; if 0 then set g2301o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2301 rows=' rows;
else do; set g2301o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2301';
else put 'ERROR: ROUND5_FAIL=G2301 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2301:; quit;
