/* R949 temporary_file_roundtrip, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/parse_grasp_covid_database_using_transwrd_and_prxmatch.sas:2 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 10; put x; end; run;
data r949a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table r949o as select sum(x) as actual from r949a; quit;

data _null_; if 0 then set r949o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R949 rows=' rows;
else do; set r949o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R949';
else put 'ERROR: ROUND2_FAIL=R949 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r949:; quit;
