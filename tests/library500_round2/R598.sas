/* R598 sql_case, N=9; source: SAS-Useful-Codes/Macros/AddMissingTag4Grps.sas:14 */

data r598a; do x=-9 to 9; output; end; run;
proc sql; create table r598o as select sum(case when x<0 then -2*x else x end) as actual from r598a; quit;

data _null_; if 0 then set r598o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R598 rows=' rows;
else do; set r598o; if not missing(actual) and abs(actual-(135))<=1e-10*max(1,abs(135)) then put 'ROUND2_PASS=R598';
else put 'ERROR: ROUND2_FAIL=R598 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r598:; quit;
