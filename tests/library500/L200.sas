/* L200: coalesce boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:34 */
data _null_;
actual=coalesce(.,.A,9,999);
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L200';
else put 'ERROR: LIB500_FAIL=L200 actual=' actual;
run;
