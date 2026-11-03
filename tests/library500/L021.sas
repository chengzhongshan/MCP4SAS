/* L021: floor boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/pre_hapassoc_sas_iml.sas:8 */
data _null_;
actual=floor(-5.25);
if not missing(actual) and abs(actual-(-6)) <= 1e-11*max(1,abs(-6)) then put 'LIB500_PASS=L021';
else put 'ERROR: LIB500_FAIL=L021 actual=' actual;
run;
