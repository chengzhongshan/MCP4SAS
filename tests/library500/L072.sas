/* L072: sqrt boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:11 */
data _null_;
actual=sqrt(1);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L072';
else put 'ERROR: LIB500_FAIL=L072 actual=' actual;
run;
