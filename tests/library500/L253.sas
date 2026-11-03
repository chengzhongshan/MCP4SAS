/* L253: reverse boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/convert_string_into_vector_using_cshape_in_proc_iml.sas:4 */
data _null_;
length actual $256;
actual=reverse('ab2Z');
if actual='Z2ba' and lengthn(actual)=4 then put 'LIB500_PASS=L253';
else put 'ERROR: LIB500_FAIL=L253 actual=' actual;
run;
