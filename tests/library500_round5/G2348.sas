/* G2348 missover_multiple_records, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put '9'; put '10 7'; run;
data g2348a; infile rtemp missover; input a b; run;
filename rtemp clear;
proc sql; create table g2348o as select sum(a)+sum(missing(b)) as actual from g2348a; quit;

data _null_; if 0 then set g2348o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2348 rows=' rows;
else do; set g2348o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND5_PASS=G2348';
else put 'ERROR: ROUND5_FAIL=G2348 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2348:; quit;
