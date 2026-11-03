/* G2341 missover_multiple_records, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put '2'; put '3 7'; run;
data g2341a; infile rtemp missover; input a b; run;
filename rtemp clear;
proc sql; create table g2341o as select sum(a)+sum(missing(b)) as actual from g2341a; quit;

data _null_; if 0 then set g2341o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2341 rows=' rows;
else do; set g2341o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2341';
else put 'ERROR: ROUND5_FAIL=G2341 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2341:; quit;
