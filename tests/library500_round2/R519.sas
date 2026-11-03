/* R519 sql_group_having, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:1 */

data r519a; do k=1 to 10; do j=1 to k; output; end; end; run;
proc sql; create table r519b as select k,count(*) as cnt from r519a group by k having count(*)>1;
create table r519o as select sum(cnt) as actual from r519b; quit;

data _null_; if 0 then set r519o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R519 rows=' rows;
else do; set r519o; if not missing(actual) and abs(actual-(54))<=1e-10*max(1,abs(54)) then put 'ROUND2_PASS=R519';
else put 'ERROR: ROUND2_FAIL=R519 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r519:; quit;
