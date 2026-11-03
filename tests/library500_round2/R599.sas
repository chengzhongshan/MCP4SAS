/* R599 sql_case, N=10; source: SAS-Useful-Codes/Macros/AddMissingTag4Grps.sas:14 */

data r599a; do x=-10 to 10; output; end; run;
proc sql; create table r599o as select sum(case when x<0 then -2*x else x end) as actual from r599a; quit;

data _null_; if 0 then set r599o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R599 rows=' rows;
else do; set r599o; if not missing(actual) and abs(actual-(165))<=1e-10*max(1,abs(165)) then put 'ROUND2_PASS=R599';
else put 'ERROR: ROUND2_FAIL=R599 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r599:; quit;
