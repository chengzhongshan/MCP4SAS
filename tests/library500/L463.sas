/* L463: input boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:29 */
data _null_;
actual=input('019',3.);
if not missing(actual) and abs(actual-(19)) <= 1e-11*max(1,abs(19)) then put 'LIB500_PASS=L463';
else put 'ERROR: LIB500_FAIL=L463 actual=' actual;
run;
