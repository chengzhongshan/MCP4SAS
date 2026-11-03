/* L401: datepart boundary 0; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:728 */
data _null_;
actual=datepart('01JAN2020:12:34:56'dt+0);
if not missing(actual) and abs(actual-(21915)) <= 1e-11*max(1,abs(21915)) then put 'LIB500_PASS=L401';
else put 'ERROR: LIB500_FAIL=L401 actual=' actual;
run;
