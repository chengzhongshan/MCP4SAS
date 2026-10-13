/* Self-contained synthetic test for code passed to execution APIs. */
data _null_;
  call execute('%let deferred_literal=%nrstr(%deferred_never_called());');
run;
data deferred_result;
  length first second $100;
  first=symget('deferred_literal');
  rc=dosubl('%let immediate_literal=%nrstr(%immediate_never_called());');
  second=symget('immediate_literal');
  valid=(first='%deferred_never_called()'
         and second='%immediate_never_called()' and rc=0);
run;
data _null_;
  set deferred_result;
  if valid then put 'LIBRARY_DEFERRED_QUOTE_OK';
  else put 'ERROR: deferred quoting calculation failed';
run;
proc print data=deferred_result; run;
