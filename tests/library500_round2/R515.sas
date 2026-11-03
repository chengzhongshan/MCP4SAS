/* R515 sql_group_having, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:1 */

data r515a; do k=1 to 6; do j=1 to k; output; end; end; run;
proc sql; create table r515b as select k,count(*) as cnt from r515a group by k having count(*)>1;
create table r515o as select sum(cnt) as actual from r515b; quit;

data _null_; if 0 then set r515o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R515 rows=' rows;
else do; set r515o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND2_PASS=R515';
else put 'ERROR: ROUND2_FAIL=R515 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r515:; quit;
