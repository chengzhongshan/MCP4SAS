/* L100: log boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/hpgenselect_hpgenselect_and_other_hp_procedures_demo.sas:155 */
data _null_;
actual=log(10);
if not missing(actual) and abs(actual-(2.302585092994046)) <= 1e-11*max(1,abs(2.302585092994046)) then put 'LIB500_PASS=L100';
else put 'ERROR: LIB500_FAIL=L100 actual=' actual;
run;
