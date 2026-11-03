/* G2343 missover_multiple_records, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put '4'; put '5 7'; run;
data g2343a; infile rtemp missover; input a b; run;
filename rtemp clear;
proc sql; create table g2343o as select sum(a)+sum(missing(b)) as actual from g2343a; quit;

data _null_; if 0 then set g2343o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2343 rows=' rows;
else do; set g2343o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2343';
else put 'ERROR: ROUND5_FAIL=G2343 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2343:; quit;
