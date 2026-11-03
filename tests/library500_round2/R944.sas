/* R944 temporary_file_roundtrip, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/parse_grasp_covid_database_using_transwrd_and_prxmatch.sas:2 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 5; put x; end; run;
data r944a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table r944o as select sum(x) as actual from r944a; quit;

data _null_; if 0 then set r944o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R944 rows=' rows;
else do; set r944o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R944';
else put 'ERROR: ROUND2_FAIL=R944 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r944:; quit;
