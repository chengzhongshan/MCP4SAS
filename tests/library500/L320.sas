/* L320: tranwrd boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:63 */
data _null_;
length actual $256;
actual=tranwrd('one-9-one','one','two');
if actual='two-9-two' and lengthn(actual)=9 then put 'LIB500_PASS=L320';
else put 'ERROR: LIB500_FAIL=L320 actual=' actual;
run;
