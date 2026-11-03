/* R945 temporary_file_roundtrip, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/parse_grasp_covid_database_using_transwrd_and_prxmatch.sas:2 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 6; put x; end; run;
data r945a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table r945o as select sum(x) as actual from r945a; quit;

data _null_; if 0 then set r945o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R945 rows=' rows;
else do; set r945o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R945';
else put 'ERROR: ROUND2_FAIL=R945 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r945:; quit;
