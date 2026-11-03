/* R520 sql_group_having, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:1 */

data r520a; do k=1 to 11; do j=1 to k; output; end; end; run;
proc sql; create table r520b as select k,count(*) as cnt from r520a group by k having count(*)>1;
create table r520o as select sum(cnt) as actual from r520b; quit;

data _null_; if 0 then set r520o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R520 rows=' rows;
else do; set r520o; if not missing(actual) and abs(actual-(65))<=1e-10*max(1,abs(65)) then put 'ROUND2_PASS=R520';
else put 'ERROR: ROUND2_FAIL=R520 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r520:; quit;
