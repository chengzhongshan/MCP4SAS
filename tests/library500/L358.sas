/* L358: index boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
actual=index('xxxxxxxneedle','needle');
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L358';
else put 'ERROR: LIB500_FAIL=L358 actual=' actual;
run;
