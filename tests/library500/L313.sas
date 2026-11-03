/* L313: tranwrd boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:63 */
data _null_;
length actual $256;
actual=tranwrd('one-2-one','one','two');
if actual='two-2-two' and lengthn(actual)=9 then put 'LIB500_PASS=L313';
else put 'ERROR: LIB500_FAIL=L313 actual=' actual;
run;
