/* R946 temporary_file_roundtrip, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/parse_grasp_covid_database_using_transwrd_and_prxmatch.sas:2 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 7; put x; end; run;
data r946a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table r946o as select sum(x) as actual from r946a; quit;

data _null_; if 0 then set r946o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R946 rows=' rows;
else do; set r946o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND2_PASS=R946';
else put 'ERROR: ROUND2_FAIL=R946 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r946:; quit;
