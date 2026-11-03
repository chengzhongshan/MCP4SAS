/* L301: compress boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */
data _null_;
length actual $256;
actual=compress(' a 0 b ');
if actual='a0b' and lengthn(actual)=3 then put 'LIB500_PASS=L301';
else put 'ERROR: LIB500_FAIL=L301 actual=' actual;
run;
