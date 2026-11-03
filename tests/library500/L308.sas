/* L308: compress boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */
data _null_;
length actual $256;
actual=compress(' a 7 b ');
if actual='a7b' and lengthn(actual)=3 then put 'LIB500_PASS=L308';
else put 'ERROR: LIB500_FAIL=L308 actual=' actual;
run;
