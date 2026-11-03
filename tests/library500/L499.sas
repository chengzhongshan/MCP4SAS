/* L499: trim boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:9 */
data _null_;
length actual $256;
actual=trim('  q8   ');
if actual='  q8' and lengthn(actual)=4 then put 'LIB500_PASS=L499';
else put 'ERROR: LIB500_FAIL=L499 actual=' actual;
run;
