/* L076: sqrt boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:11 */
data _null_;
actual=sqrt(25);
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L076';
else put 'ERROR: LIB500_FAIL=L076 actual=' actual;
run;
