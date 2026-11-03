/* L197: coalesce boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:34 */
data _null_;
actual=coalesce(.,.A,6,999);
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L197';
else put 'ERROR: LIB500_FAIL=L197 actual=' actual;
run;
