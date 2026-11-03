/* L191: coalesce boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:34 */
data _null_;
actual=coalesce(.,.A,0,999);
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L191';
else put 'ERROR: LIB500_FAIL=L191 actual=' actual;
run;
