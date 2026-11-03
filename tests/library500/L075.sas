/* L075: sqrt boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:11 */
data _null_;
actual=sqrt(16);
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L075';
else put 'ERROR: LIB500_FAIL=L075 actual=' actual;
run;
