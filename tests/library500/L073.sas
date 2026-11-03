/* L073: sqrt boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:11 */
data _null_;
actual=sqrt(4);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L073';
else put 'ERROR: LIB500_FAIL=L073 actual=' actual;
run;
