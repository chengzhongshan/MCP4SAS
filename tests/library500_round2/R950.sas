/* R950 temporary_file_roundtrip, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/parse_grasp_covid_database_using_transwrd_and_prxmatch.sas:2 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 11; put x; end; run;
data r950a; infile rtemp; input x; run;
filename rtemp clear;
proc sql; create table r950o as select sum(x) as actual from r950a; quit;

data _null_; if 0 then set r950o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R950 rows=' rows;
else do; set r950o; if not missing(actual) and abs(actual-(66))<=1e-10*max(1,abs(66)) then put 'ROUND2_PASS=R950';
else put 'ERROR: ROUND2_FAIL=R950 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r950:; quit;
