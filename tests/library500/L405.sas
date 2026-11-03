/* L405: datepart boundary 4; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:728 */
data _null_;
actual=datepart('01JAN2020:12:34:56'dt+345600);
if not missing(actual) and abs(actual-(21919)) <= 1e-11*max(1,abs(21919)) then put 'LIB500_PASS=L405';
else put 'ERROR: LIB500_FAIL=L405 actual=' actual;
run;
