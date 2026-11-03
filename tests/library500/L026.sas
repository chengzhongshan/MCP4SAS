/* L026: floor boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/pre_hapassoc_sas_iml.sas:8 */
data _null_;
actual=floor(-0.25);
if not missing(actual) and abs(actual-(-1)) <= 1e-11*max(1,abs(-1)) then put 'LIB500_PASS=L026';
else put 'ERROR: LIB500_FAIL=L026 actual=' actual;
run;
