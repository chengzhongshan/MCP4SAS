/* R943 temporary_file_roundtrip, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/parse_grasp_covid_database_using_transwrd_and_prxmatch.sas:2 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 4; put x; end; run;
data r943a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table r943o as select sum(x) as actual from r943a; quit;

data _null_; if 0 then set r943o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R943 rows=' rows;
else do; set r943o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R943';
else put 'ERROR: ROUND2_FAIL=R943 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r943:; quit;
