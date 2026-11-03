/* L194: coalesce boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:34 */
data _null_;
actual=coalesce(.,.A,3,999);
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L194';
else put 'ERROR: LIB500_FAIL=L194 actual=' actual;
run;
