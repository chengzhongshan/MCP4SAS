/* L027: floor boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/pre_hapassoc_sas_iml.sas:8 */
data _null_;
actual=floor(0.75);
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L027';
else put 'ERROR: LIB500_FAIL=L027 actual=' actual;
run;
