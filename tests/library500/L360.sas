/* L360: index boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
actual=index('xxxxxxxxxneedle','needle');
if not missing(actual) and abs(actual-(10)) <= 1e-11*max(1,abs(10)) then put 'LIB500_PASS=L360';
else put 'ERROR: LIB500_FAIL=L360 actual=' actual;
run;
