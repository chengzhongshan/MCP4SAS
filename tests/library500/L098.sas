/* L098: log boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/hpgenselect_hpgenselect_and_other_hp_procedures_demo.sas:155 */
data _null_;
actual=log(8);
if not missing(actual) and abs(actual-(2.079441541679836)) <= 1e-11*max(1,abs(2.079441541679836)) then put 'LIB500_PASS=L098';
else put 'ERROR: LIB500_FAIL=L098 actual=' actual;
run;
