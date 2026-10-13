/* Standalone synthetic example for nested macro quoting and literal tokens. */
%let nested_text=%bquote(%nrstr(%nested_literal_never_executed()));
data nested_quote_result;
  length nested quoted $100;
  nested=symget('nested_text');
  quoted="%nrstr(%quoted_literal_never_executed())";
  valid=(nested='%nested_literal_never_executed()'
         and quoted='%quoted_literal_never_executed()');
run;
data _null_;
  set nested_quote_result;
  if valid then put 'LIBRARY_NESTED_QUOTE_OK';
  else put 'ERROR: nested quote calculation failed';
run;
proc print data=nested_quote_result; run;
