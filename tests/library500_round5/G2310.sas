/* G2310 single_at_conditional_input, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

filename rtemp temp;
data _null_; file rtemp; put 'skip junk'; put 'keep 11'; put 'keep 12'; run;
data g2310a; infile rtemp; input key $ @; if key='keep' then input value; else delete; run;
filename rtemp clear;
proc sql; create table g2310o as select sum(value) as actual from g2310a; quit;

data _null_; if 0 then set g2310o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2310 rows=' rows;
else do; set g2310o; if not missing(actual) and abs(actual-(23))<=1e-9*max(1,abs(23)) then put 'ROUND5_PASS=G2310';
else put 'ERROR: ROUND5_FAIL=G2310 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2310:; quit;
