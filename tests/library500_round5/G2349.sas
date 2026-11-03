/* G2349 missover_multiple_records, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put '10'; put '11 7'; run;
data g2349a; infile rtemp missover; input a b; run;
filename rtemp clear;
proc sql; create table g2349o as select sum(a)+sum(missing(b)) as actual from g2349a; quit;

data _null_; if 0 then set g2349o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2349 rows=' rows;
else do; set g2349o; if not missing(actual) and abs(actual-(22))<=1e-9*max(1,abs(22)) then put 'ROUND5_PASS=G2349';
else put 'ERROR: ROUND5_FAIL=G2349 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2349:; quit;
