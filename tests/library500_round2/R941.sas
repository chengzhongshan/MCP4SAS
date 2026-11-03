/* R941 temporary_file_roundtrip, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/parse_grasp_covid_database_using_transwrd_and_prxmatch.sas:2 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 2; put x; end; run;
data r941a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table r941o as select sum(x) as actual from r941a; quit;

data _null_; if 0 then set r941o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R941 rows=' rows;
else do; set r941o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R941';
else put 'ERROR: ROUND2_FAIL=R941 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r941:; quit;
