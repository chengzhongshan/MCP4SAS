/* R595 sql_case, N=6; source: SAS-Useful-Codes/Macros/AddMissingTag4Grps.sas:14 */

data r595a; do x=-6 to 6; output; end; run;
proc sql; create table r595o as select sum(case when x<0 then -2*x else x end) as actual from r595a; quit;

data _null_; if 0 then set r595o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R595 rows=' rows;
else do; set r595o; if not missing(actual) and abs(actual-(63))<=1e-10*max(1,abs(63)) then put 'ROUND2_PASS=R595';
else put 'ERROR: ROUND2_FAIL=R595 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r595:; quit;
