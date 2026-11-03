/* L317: tranwrd boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:63 */
data _null_;
length actual $256;
actual=tranwrd('one-6-one','one','two');
if actual='two-6-two' and lengthn(actual)=9 then put 'LIB500_PASS=L317';
else put 'ERROR: LIB500_FAIL=L317 actual=' actual;
run;
