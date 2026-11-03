/* R596 sql_case, N=7; source: SAS-Useful-Codes/Macros/AddMissingTag4Grps.sas:14 */

data r596a; do x=-7 to 7; output; end; run;
proc sql; create table r596o as select sum(case when x<0 then -2*x else x end) as actual from r596a; quit;

data _null_; if 0 then set r596o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R596 rows=' rows;
else do; set r596o; if not missing(actual) and abs(actual-(84))<=1e-10*max(1,abs(84)) then put 'ROUND2_PASS=R596';
else put 'ERROR: ROUND2_FAIL=R596 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r596:; quit;
