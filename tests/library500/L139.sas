/* L139: sum boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_manhattan_using_cumulative_sum_of_proc_sql.sas:78 */
data _null_;
actual=sum(.,8,11);
if not missing(actual) and abs(actual-(19)) <= 1e-11*max(1,abs(19)) then put 'LIB500_PASS=L139';
else put 'ERROR: LIB500_FAIL=L139 actual=' actual;
run;
