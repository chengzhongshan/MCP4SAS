/* L469: input boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:29 */
data _null_;
actual=input('025',3.);
if not missing(actual) and abs(actual-(25)) <= 1e-11*max(1,abs(25)) then put 'LIB500_PASS=L469';
else put 'ERROR: LIB500_FAIL=L469 actual=' actual;
run;
