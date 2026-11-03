/* L140: sum boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_manhattan_using_cumulative_sum_of_proc_sql.sas:78 */
data _null_;
actual=sum(.,9,12);
if not missing(actual) and abs(actual-(21)) <= 1e-11*max(1,abs(21)) then put 'LIB500_PASS=L140';
else put 'ERROR: LIB500_FAIL=L140 actual=' actual;
run;
