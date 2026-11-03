/* G2309 single_at_conditional_input, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

filename rtemp temp;
data _null_; file rtemp; put 'skip junk'; put 'keep 10'; put 'keep 11'; run;
data g2309a; infile rtemp; input key $ @; if key='keep' then input value; else delete; run;
filename rtemp clear;
proc sql; create table g2309o as select sum(value) as actual from g2309a; quit;

data _null_; if 0 then set g2309o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2309 rows=' rows;
else do; set g2309o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND5_PASS=G2309';
else put 'ERROR: ROUND5_FAIL=G2309 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2309:; quit;
