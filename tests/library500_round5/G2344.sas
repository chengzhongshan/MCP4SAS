/* G2344 missover_multiple_records, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put '5'; put '6 7'; run;
data g2344a; infile rtemp missover; input a b; run;
filename rtemp clear;
proc sql; create table g2344o as select sum(a)+sum(missing(b)) as actual from g2344a; quit;

data _null_; if 0 then set g2344o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2344 rows=' rows;
else do; set g2344o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND5_PASS=G2344';
else put 'ERROR: ROUND5_FAIL=G2344 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2344:; quit;
