/* L134: sum boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_manhattan_using_cumulative_sum_of_proc_sql.sas:78 */
data _null_;
actual=sum(.,3,6);
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L134';
else put 'ERROR: LIB500_FAIL=L134 actual=' actual;
run;
