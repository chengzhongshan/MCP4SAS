/* L137: sum boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_manhattan_using_cumulative_sum_of_proc_sql.sas:78 */
data _null_;
actual=sum(.,6,9);
if not missing(actual) and abs(actual-(15)) <= 1e-11*max(1,abs(15)) then put 'LIB500_PASS=L137';
else put 'ERROR: LIB500_FAIL=L137 actual=' actual;
run;
