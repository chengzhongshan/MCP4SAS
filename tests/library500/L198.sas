/* L198: coalesce boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:34 */
data _null_;
actual=coalesce(.,.A,7,999);
if not missing(actual) and abs(actual-(7)) <= 1e-11*max(1,abs(7)) then put 'LIB500_PASS=L198';
else put 'ERROR: LIB500_FAIL=L198 actual=' actual;
run;
