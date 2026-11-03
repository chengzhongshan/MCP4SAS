/* G2350 missover_multiple_records, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put '11'; put '12 7'; run;
data g2350a; infile rtemp missover; input a b; run;
filename rtemp clear;
proc sql; create table g2350o as select sum(a)+sum(missing(b)) as actual from g2350a; quit;

data _null_; if 0 then set g2350o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2350 rows=' rows;
else do; set g2350o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND5_PASS=G2350';
else put 'ERROR: ROUND5_FAIL=G2350 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2350:; quit;
