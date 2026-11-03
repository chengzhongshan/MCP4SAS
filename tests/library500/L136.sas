/* L136: sum boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_manhattan_using_cumulative_sum_of_proc_sql.sas:78 */
data _null_;
actual=sum(.,5,8);
if not missing(actual) and abs(actual-(13)) <= 1e-11*max(1,abs(13)) then put 'LIB500_PASS=L136';
else put 'ERROR: LIB500_FAIL=L136 actual=' actual;
run;
