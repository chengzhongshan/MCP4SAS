/* L023: floor boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/pre_hapassoc_sas_iml.sas:8 */
data _null_;
actual=floor(-3.25);
if not missing(actual) and abs(actual-(-4)) <= 1e-11*max(1,abs(-4)) then put 'LIB500_PASS=L023';
else put 'ERROR: LIB500_FAIL=L023 actual=' actual;
run;
