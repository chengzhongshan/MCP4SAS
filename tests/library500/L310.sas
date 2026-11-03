/* L310: compress boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */
data _null_;
length actual $256;
actual=compress(' a 9 b ');
if actual='a9b' and lengthn(actual)=3 then put 'LIB500_PASS=L310';
else put 'ERROR: LIB500_FAIL=L310 actual=' actual;
run;
