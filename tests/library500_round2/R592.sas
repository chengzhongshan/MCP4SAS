/* R592 sql_case, N=3; source: SAS-Useful-Codes/Macros/AddMissingTag4Grps.sas:14 */

data r592a; do x=-3 to 3; output; end; run;
proc sql; create table r592o as select sum(case when x<0 then -2*x else x end) as actual from r592a; quit;

data _null_; if 0 then set r592o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R592 rows=' rows;
else do; set r592o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND2_PASS=R592';
else put 'ERROR: ROUND2_FAIL=R592 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r592:; quit;
