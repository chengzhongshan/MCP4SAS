/* L196: coalesce boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:34 */
data _null_;
actual=coalesce(.,.A,5,999);
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L196';
else put 'ERROR: LIB500_FAIL=L196 actual=' actual;
run;
