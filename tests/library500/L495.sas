/* L495: trim boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:9 */
data _null_;
length actual $256;
actual=trim('  q4   ');
if actual='  q4' and lengthn(actual)=4 then put 'LIB500_PASS=L495';
else put 'ERROR: LIB500_FAIL=L495 actual=' actual;
run;
