/* L093: log boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/hpgenselect_hpgenselect_and_other_hp_procedures_demo.sas:155 */
data _null_;
actual=log(3);
if not missing(actual) and abs(actual-(1.09861228866811)) <= 1e-11*max(1,abs(1.09861228866811)) then put 'LIB500_PASS=L093';
else put 'ERROR: LIB500_FAIL=L093 actual=' actual;
run;
