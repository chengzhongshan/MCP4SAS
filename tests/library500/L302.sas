/* L302: compress boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:26 */
data _null_;
length actual $256;
actual=compress(' a 1 b ');
if actual='a1b' and lengthn(actual)=3 then put 'LIB500_PASS=L302';
else put 'ERROR: LIB500_FAIL=L302 actual=' actual;
run;
