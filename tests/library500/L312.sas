/* L312: tranwrd boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:63 */
data _null_;
length actual $256;
actual=tranwrd('one-1-one','one','two');
if actual='two-1-two' and lengthn(actual)=9 then put 'LIB500_PASS=L312';
else put 'ERROR: LIB500_FAIL=L312 actual=' actual;
run;
