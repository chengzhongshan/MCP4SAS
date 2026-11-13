/* Beginner example: SASHELP.CLASS is a SAS teaching dataset, not a study cohort. */
options notes source nodate nonumber;
%let BOOK_OUT=%sysfunc(pathname(work));
%put POC_OUT=&BOOK_OUT;

data work.hello;
  set sashelp.class;
run;

proc print data=work.hello(obs=5) noobs;
run;

proc export data=work.hello outfile="&BOOK_OUT/hello.csv" dbms=csv replace;
run;
%put POC_COMPLETE=hello;
