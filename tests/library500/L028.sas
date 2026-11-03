/* L028: floor boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/pre_hapassoc_sas_iml.sas:8 */
data _null_;
actual=floor(1.75);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L028';
else put 'ERROR: LIB500_FAIL=L028 actual=' actual;
run;
