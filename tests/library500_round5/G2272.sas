/* G2272 input_slash_pointer, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:26 */

filename rtemp temp;
data _null_; file rtemp; put '3'; put '4'; run;
data g2272o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;

data _null_; if 0 then set g2272o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2272 rows=' rows;
else do; set g2272o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2272';
else put 'ERROR: ROUND5_FAIL=G2272 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2272:; quit;
