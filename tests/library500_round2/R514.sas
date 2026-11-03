/* R514 sql_group_having, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:1 */

data r514a; do k=1 to 5; do j=1 to k; output; end; end; run;
proc sql; create table r514b as select k,count(*) as cnt from r514a group by k having count(*)>1;
create table r514o as select sum(cnt) as actual from r514b; quit;

data _null_; if 0 then set r514o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R514 rows=' rows;
else do; set r514o; if not missing(actual) and abs(actual-(14))<=1e-10*max(1,abs(14)) then put 'ROUND2_PASS=R514';
else put 'ERROR: ROUND2_FAIL=R514 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r514:; quit;
