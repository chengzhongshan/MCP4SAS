/* L029: floor boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/pre_hapassoc_sas_iml.sas:8 */
data _null_;
actual=floor(2.75);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L029';
else put 'ERROR: LIB500_FAIL=L029 actual=' actual;
run;
