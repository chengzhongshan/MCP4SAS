/* G2345 missover_multiple_records, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put '6'; put '7 7'; run;
data g2345a; infile rtemp missover; input a b; run;
filename rtemp clear;
proc sql; create table g2345o as select sum(a)+sum(missing(b)) as actual from g2345a; quit;

data _null_; if 0 then set g2345o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2345 rows=' rows;
else do; set g2345o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND5_PASS=G2345';
else put 'ERROR: ROUND5_FAIL=G2345 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2345:; quit;
