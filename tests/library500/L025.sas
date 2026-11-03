/* L025: floor boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/pre_hapassoc_sas_iml.sas:8 */
data _null_;
actual=floor(-1.25);
if not missing(actual) and abs(actual-(-2)) <= 1e-11*max(1,abs(-2)) then put 'LIB500_PASS=L025';
else put 'ERROR: LIB500_FAIL=L025 actual=' actual;
run;
