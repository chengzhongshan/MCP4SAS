/* L464: input boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:29 */
data _null_;
actual=input('020',3.);
if not missing(actual) and abs(actual-(20)) <= 1e-11*max(1,abs(20)) then put 'LIB500_PASS=L464';
else put 'ERROR: LIB500_FAIL=L464 actual=' actual;
run;
