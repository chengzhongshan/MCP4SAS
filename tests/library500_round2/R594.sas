/* R594 sql_case, N=5; source: SAS-Useful-Codes/Macros/AddMissingTag4Grps.sas:14 */

data r594a; do x=-5 to 5; output; end; run;
proc sql; create table r594o as select sum(case when x<0 then -2*x else x end) as actual from r594a; quit;

data _null_; if 0 then set r594o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R594 rows=' rows;
else do; set r594o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R594';
else put 'ERROR: ROUND2_FAIL=R594 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r594:; quit;
