/* L500: trim boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:9 */
data _null_;
length actual $256;
actual=trim('  q9   ');
if actual='  q9' and lengthn(actual)=4 then put 'LIB500_PASS=L500';
else put 'ERROR: LIB500_FAIL=L500 actual=' actual;
run;
