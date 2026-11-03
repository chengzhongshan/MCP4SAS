/* L252: reverse boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/convert_string_into_vector_using_cshape_in_proc_iml.sas:4 */
data _null_;
length actual $256;
actual=reverse('ab1Z');
if actual='Z1ba' and lengthn(actual)=4 then put 'LIB500_PASS=L252';
else put 'ERROR: LIB500_FAIL=L252 actual=' actual;
run;
