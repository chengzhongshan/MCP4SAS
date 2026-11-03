/* R591 sql_case, N=2; source: SAS-Useful-Codes/Macros/AddMissingTag4Grps.sas:14 */

data r591a; do x=-2 to 2; output; end; run;
proc sql; create table r591o as select sum(case when x<0 then -2*x else x end) as actual from r591a; quit;

data _null_; if 0 then set r591o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R591 rows=' rows;
else do; set r591o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R591';
else put 'ERROR: ROUND2_FAIL=R591 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r591:; quit;
