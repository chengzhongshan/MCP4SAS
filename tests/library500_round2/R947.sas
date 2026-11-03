/* R947 temporary_file_roundtrip, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/parse_grasp_covid_database_using_transwrd_and_prxmatch.sas:2 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 8; put x; end; run;
data r947a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table r947o as select sum(x) as actual from r947a; quit;

data _null_; if 0 then set r947o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R947 rows=' rows;
else do; set r947o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R947';
else put 'ERROR: ROUND2_FAIL=R947 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r947:; quit;
