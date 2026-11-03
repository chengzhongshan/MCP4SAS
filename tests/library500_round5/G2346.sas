/* G2346 missover_multiple_records, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:22 */

filename rtemp temp;
data _null_; file rtemp; put '7'; put '8 7'; run;
data g2346a; infile rtemp missover; input a b; run;
filename rtemp clear;
proc sql; create table g2346o as select sum(a)+sum(missing(b)) as actual from g2346a; quit;

data _null_; if 0 then set g2346o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2346 rows=' rows;
else do; set g2346o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND5_PASS=G2346';
else put 'ERROR: ROUND5_FAIL=G2346 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2346:; quit;
