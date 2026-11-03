/* G2347 missover_multiple_records, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put '8'; put '9 7'; run;
data g2347a; infile rtemp missover; input a b; run;
filename rtemp clear;
proc sql; create table g2347o as select sum(a)+sum(missing(b)) as actual from g2347a; quit;

data _null_; if 0 then set g2347o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2347 rows=' rows;
else do; set g2347o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND5_PASS=G2347';
else put 'ERROR: ROUND5_FAIL=G2347 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2347:; quit;
