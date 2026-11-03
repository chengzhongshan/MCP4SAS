/* L359: index boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
actual=index('xxxxxxxxneedle','needle');
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L359';
else put 'ERROR: LIB500_FAIL=L359 actual=' actual;
run;
