/* L195: coalesce boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:34 */
data _null_;
actual=coalesce(.,.A,4,999);
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L195';
else put 'ERROR: LIB500_FAIL=L195 actual=' actual;
run;
