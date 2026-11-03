/* L132: sum boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_manhattan_using_cumulative_sum_of_proc_sql.sas:78 */
data _null_;
actual=sum(.,1,4);
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L132';
else put 'ERROR: LIB500_FAIL=L132 actual=' actual;
run;
