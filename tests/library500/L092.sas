/* L092: log boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/hpgenselect_hpgenselect_and_other_hp_procedures_demo.sas:155 */
data _null_;
actual=log(2);
if not missing(actual) and abs(actual-(0.6931471805599453)) <= 1e-11*max(1,abs(0.6931471805599453)) then put 'LIB500_PASS=L092';
else put 'ERROR: LIB500_FAIL=L092 actual=' actual;
run;
