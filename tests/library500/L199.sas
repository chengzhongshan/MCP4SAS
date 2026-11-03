/* L199: coalesce boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:34 */
data _null_;
actual=coalesce(.,.A,8,999);
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L199';
else put 'ERROR: LIB500_FAIL=L199 actual=' actual;
run;
