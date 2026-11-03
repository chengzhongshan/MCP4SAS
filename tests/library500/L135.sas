/* L135: sum boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_manhattan_using_cumulative_sum_of_proc_sql.sas:78 */
data _null_;
actual=sum(.,4,7);
if not missing(actual) and abs(actual-(11)) <= 1e-11*max(1,abs(11)) then put 'LIB500_PASS=L135';
else put 'ERROR: LIB500_FAIL=L135 actual=' actual;
run;
