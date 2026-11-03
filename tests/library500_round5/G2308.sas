/* G2308 single_at_conditional_input, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

filename rtemp temp;
data _null_; file rtemp; put 'skip junk'; put 'keep 9'; put 'keep 10'; run;
data g2308a; infile rtemp; input key $ @; if key='keep' then input value; else delete; run;
filename rtemp clear;
proc sql; create table g2308o as select sum(value) as actual from g2308a; quit;

data _null_; if 0 then set g2308o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2308 rows=' rows;
else do; set g2308o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND5_PASS=G2308';
else put 'ERROR: ROUND5_FAIL=G2308 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2308:; quit;
