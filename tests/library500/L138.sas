/* L138: sum boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_manhattan_using_cumulative_sum_of_proc_sql.sas:78 */
data _null_;
actual=sum(.,7,10);
if not missing(actual) and abs(actual-(17)) <= 1e-11*max(1,abs(17)) then put 'LIB500_PASS=L138';
else put 'ERROR: LIB500_FAIL=L138 actual=' actual;
run;
