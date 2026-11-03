/* L192: coalesce boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:34 */
data _null_;
actual=coalesce(.,.A,1,999);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L192';
else put 'ERROR: LIB500_FAIL=L192 actual=' actual;
run;
