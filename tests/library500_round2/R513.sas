/* R513 sql_group_having, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:1 */

data r513a; do k=1 to 4; do j=1 to k; output; end; end; run;
proc sql; create table r513b as select k,count(*) as cnt from r513a group by k having count(*)>1;
create table r513o as select sum(cnt) as actual from r513b; quit;

data _null_; if 0 then set r513o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R513 rows=' rows;
else do; set r513o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R513';
else put 'ERROR: ROUND2_FAIL=R513 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r513:; quit;
