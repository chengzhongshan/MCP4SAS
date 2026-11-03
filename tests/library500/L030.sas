/* L030: floor boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/pre_hapassoc_sas_iml.sas:8 */
data _null_;
actual=floor(3.75);
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L030';
else put 'ERROR: LIB500_FAIL=L030 actual=' actual;
run;
