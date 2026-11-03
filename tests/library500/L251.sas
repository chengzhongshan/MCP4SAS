/* L251: reverse boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/convert_string_into_vector_using_cshape_in_proc_iml.sas:4 */
data _null_;
length actual $256;
actual=reverse('ab0Z');
if actual='Z0ba' and lengthn(actual)=4 then put 'LIB500_PASS=L251';
else put 'ERROR: LIB500_FAIL=L251 actual=' actual;
run;
