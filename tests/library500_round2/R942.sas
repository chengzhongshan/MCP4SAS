/* R942 temporary_file_roundtrip, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/parse_grasp_covid_database_using_transwrd_and_prxmatch.sas:2 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 3; put x; end; run;
data r942a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table r942o as select sum(x) as actual from r942a; quit;

data _null_; if 0 then set r942o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R942 rows=' rows;
else do; set r942o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R942';
else put 'ERROR: ROUND2_FAIL=R942 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r942:; quit;
