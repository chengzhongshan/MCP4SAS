/* L406: datepart boundary 5; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:728 */
data _null_;
actual=datepart('01JAN2020:12:34:56'dt+432000);
if not missing(actual) and abs(actual-(21920)) <= 1e-11*max(1,abs(21920)) then put 'LIB500_PASS=L406';
else put 'ERROR: LIB500_FAIL=L406 actual=' actual;
run;
