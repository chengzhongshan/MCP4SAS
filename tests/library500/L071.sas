/* L071: sqrt boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:11 */
data _null_;
actual=sqrt(0);
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L071';
else put 'ERROR: LIB500_FAIL=L071 actual=' actual;
run;
