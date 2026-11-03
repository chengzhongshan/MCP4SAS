/* R516 sql_group_having, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:1 */

data r516a; do k=1 to 7; do j=1 to k; output; end; end; run;
proc sql; create table r516b as select k,count(*) as cnt from r516a group by k having count(*)>1;
create table r516o as select sum(cnt) as actual from r516b; quit;

data _null_; if 0 then set r516o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R516 rows=' rows;
else do; set r516o; if not missing(actual) and abs(actual-(27))<=1e-10*max(1,abs(27)) then put 'ROUND2_PASS=R516';
else put 'ERROR: ROUND2_FAIL=R516 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r516:; quit;
