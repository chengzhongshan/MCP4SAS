/* R948 temporary_file_roundtrip, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/parse_grasp_covid_database_using_transwrd_and_prxmatch.sas:2 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 9; put x; end; run;
data r948a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table r948o as select sum(x) as actual from r948a; quit;

data _null_; if 0 then set r948o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R948 rows=' rows;
else do; set r948o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R948';
else put 'ERROR: ROUND2_FAIL=R948 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r948:; quit;
