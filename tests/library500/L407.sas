/* L407: datepart boundary 6; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:728 */
data _null_;
actual=datepart('01JAN2020:12:34:56'dt+518400);
if not missing(actual) and abs(actual-(21921)) <= 1e-11*max(1,abs(21921)) then put 'LIB500_PASS=L407';
else put 'ERROR: LIB500_FAIL=L407 actual=' actual;
run;
