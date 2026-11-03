/* R597 sql_case, N=8; source: SAS-Useful-Codes/Macros/AddMissingTag4Grps.sas:14 */

data r597a; do x=-8 to 8; output; end; run;
proc sql; create table r597o as select sum(case when x<0 then -2*x else x end) as actual from r597a; quit;

data _null_; if 0 then set r597o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R597 rows=' rows;
else do; set r597o; if not missing(actual) and abs(actual-(108))<=1e-10*max(1,abs(108)) then put 'ROUND2_PASS=R597';
else put 'ERROR: ROUND2_FAIL=R597 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r597:; quit;
