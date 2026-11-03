/* R600 sql_case, N=11; source: SAS-Useful-Codes/Macros/AddMissingTag4Grps.sas:14 */

data r600a; do x=-11 to 11; output; end; run;
proc sql; create table r600o as select sum(case when x<0 then -2*x else x end) as actual from r600a; quit;

data _null_; if 0 then set r600o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R600 rows=' rows;
else do; set r600o; if not missing(actual) and abs(actual-(198))<=1e-10*max(1,abs(198)) then put 'ROUND2_PASS=R600';
else put 'ERROR: ROUND2_FAIL=R600 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r600:; quit;
