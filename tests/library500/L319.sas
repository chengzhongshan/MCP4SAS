/* L319: tranwrd boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:63 */
data _null_;
length actual $256;
actual=tranwrd('one-8-one','one','two');
if actual='two-8-two' and lengthn(actual)=9 then put 'LIB500_PASS=L319';
else put 'ERROR: LIB500_FAIL=L319 actual=' actual;
run;
