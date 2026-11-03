/* L022: floor boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/pre_hapassoc_sas_iml.sas:8 */
data _null_;
actual=floor(-4.25);
if not missing(actual) and abs(actual-(-5)) <= 1e-11*max(1,abs(-5)) then put 'LIB500_PASS=L022';
else put 'ERROR: LIB500_FAIL=L022 actual=' actual;
run;
