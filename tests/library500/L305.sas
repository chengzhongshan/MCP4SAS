/* L305: compress boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */
data _null_;
length actual $256;
actual=compress(' a 4 b ');
if actual='a4b' and lengthn(actual)=3 then put 'LIB500_PASS=L305';
else put 'ERROR: LIB500_FAIL=L305 actual=' actual;
run;
