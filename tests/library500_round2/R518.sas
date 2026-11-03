/* R518 sql_group_having, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:1 */

data r518a; do k=1 to 9; do j=1 to k; output; end; end; run;
proc sql; create table r518b as select k,count(*) as cnt from r518a group by k having count(*)>1;
create table r518o as select sum(cnt) as actual from r518b; quit;

data _null_; if 0 then set r518o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R518 rows=' rows;
else do; set r518o; if not missing(actual) and abs(actual-(44))<=1e-10*max(1,abs(44)) then put 'ROUND2_PASS=R518';
else put 'ERROR: ROUND2_FAIL=R518 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r518:; quit;
