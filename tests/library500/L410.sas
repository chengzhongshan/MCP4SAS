/* L410: datepart boundary 9; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:728 */
data _null_;
actual=datepart('01JAN2020:12:34:56'dt+777600);
if not missing(actual) and abs(actual-(21924)) <= 1e-11*max(1,abs(21924)) then put 'LIB500_PASS=L410';
else put 'ERROR: LIB500_FAIL=L410 actual=' actual;
run;
