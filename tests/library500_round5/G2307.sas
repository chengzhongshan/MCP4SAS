/* G2307 single_at_conditional_input, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

filename rtemp temp;
data _null_; file rtemp; put 'skip junk'; put 'keep 8'; put 'keep 9'; run;
data g2307a; infile rtemp; input key $ @; if key='keep' then input value; else delete; run;
filename rtemp clear;
proc sql; create table g2307o as select sum(value) as actual from g2307a; quit;

data _null_; if 0 then set g2307o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2307 rows=' rows;
else do; set g2307o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND5_PASS=G2307';
else put 'ERROR: ROUND5_FAIL=G2307 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2307:; quit;
