/* L315: tranwrd boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:63 */
data _null_;
length actual $256;
actual=tranwrd('one-4-one','one','two');
if actual='two-4-two' and lengthn(actual)=9 then put 'LIB500_PASS=L315';
else put 'ERROR: LIB500_FAIL=L315 actual=' actual;
run;
