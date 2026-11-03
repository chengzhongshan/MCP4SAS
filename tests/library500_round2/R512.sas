/* R512 sql_group_having, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:1 */

data r512a; do k=1 to 3; do j=1 to k; output; end; end; run;
proc sql; create table r512b as select k,count(*) as cnt from r512a group by k having count(*)>1;
create table r512o as select sum(cnt) as actual from r512b; quit;

data _null_; if 0 then set r512o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R512 rows=' rows;
else do; set r512o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R512';
else put 'ERROR: ROUND2_FAIL=R512 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r512:; quit;
