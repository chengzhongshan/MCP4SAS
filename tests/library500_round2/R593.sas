/* R593 sql_case, N=4; source: SAS-Useful-Codes/Macros/AddMissingTag4Grps.sas:14 */

data r593a; do x=-4 to 4; output; end; run;
proc sql; create table r593o as select sum(case when x<0 then -2*x else x end) as actual from r593a; quit;

data _null_; if 0 then set r593o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R593 rows=' rows;
else do; set r593o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND2_PASS=R593';
else put 'ERROR: ROUND2_FAIL=R593 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r593:; quit;
