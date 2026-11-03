/* L259: reverse boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/convert_string_into_vector_using_cshape_in_proc_iml.sas:4 */
data _null_;
length actual $256;
actual=reverse('ab8Z');
if actual='Z8ba' and lengthn(actual)=4 then put 'LIB500_PASS=L259';
else put 'ERROR: LIB500_FAIL=L259 actual=' actual;
run;
