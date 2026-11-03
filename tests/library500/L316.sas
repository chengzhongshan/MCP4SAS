/* L316: tranwrd boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:63 */
data _null_;
length actual $256;
actual=tranwrd('one-5-one','one','two');
if actual='two-5-two' and lengthn(actual)=9 then put 'LIB500_PASS=L316';
else put 'ERROR: LIB500_FAIL=L316 actual=' actual;
run;
