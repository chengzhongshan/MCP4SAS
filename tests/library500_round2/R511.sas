/* R511 sql_group_having, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:1 */

data r511a; do k=1 to 2; do j=1 to k; output; end; end; run;
proc sql; create table r511b as select k,count(*) as cnt from r511a group by k having count(*)>1;
create table r511o as select sum(cnt) as actual from r511b; quit;

data _null_; if 0 then set r511o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R511 rows=' rows;
else do; set r511o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND2_PASS=R511';
else put 'ERROR: ROUND2_FAIL=R511 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r511:; quit;
