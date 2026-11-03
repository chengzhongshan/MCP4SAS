/* L193: coalesce boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:34 */
data _null_;
actual=coalesce(.,.A,2,999);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L193';
else put 'ERROR: LIB500_FAIL=L193 actual=' actual;
run;
