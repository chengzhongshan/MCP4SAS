/* L131: sum boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_manhattan_using_cumulative_sum_of_proc_sql.sas:78 */
data _null_;
actual=sum(.,0,3);
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L131';
else put 'ERROR: LIB500_FAIL=L131 actual=' actual;
run;
