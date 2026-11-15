/* Test-only namespaced definition from char_grp_to_num_grp4dups.sas; original SHA256 3fe50cbd907bf709eac86bc403e4d46c2a0be4cf86d6f581dbd0df3b1a195f50. */
%macro n26_char_grp_to_num_grp4dups(dsdin,grp_vars4sort,descending_or_not,dsdout,num_grp_output_name);
%let nvars=%n26_numargs(&grp_vars4sort);
data &dsdout;
set &dsdin;
%if &nvars>=1 %then %do;
grps_output_key=catx(':', of &grp_vars4sort);
%end;
%else %do;
grps_output_key=&grp_vars4sort;
%end;
run;
/*All grp keys are kept!*/
*Use key instead of by in the proc sort, as unknown error occurred when using by with descending function;
%if &descending_or_not %then %do;
proc sort data=&dsdout out=&dsdout;
key grps_output_key /descending;
run;
%end;
%else %do;
proc sort data=&dsdout out=&dsdout;
key grps_output_key;
run;
%end;

data &dsdout;
set &dsdout;
retain &num_grp_output_name 0;
if first.grps_output_key then do;
 &num_grp_output_name=&num_grp_output_name+1;
 output;
end;
else do;
 output;
end;
by grps_output_key;
run;

%mend;
