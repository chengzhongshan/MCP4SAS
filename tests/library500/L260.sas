/* L260: reverse boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/convert_string_into_vector_using_cshape_in_proc_iml.sas:4 */
data _null_;
length actual $256;
actual=reverse('ab9Z');
if actual='Z9ba' and lengthn(actual)=4 then put 'LIB500_PASS=L260';
else put 'ERROR: LIB500_FAIL=L260 actual=' actual;
run;
