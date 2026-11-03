/* L353: index boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
actual=index('xxneedle','needle');
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L353';
else put 'ERROR: LIB500_FAIL=L353 actual=' actual;
run;
