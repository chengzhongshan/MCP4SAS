/* Test-only namespaced definition from char_grp_to_num_grp.sas; original SHA256 975212504a33769674e50c58a6b7335e352a32cd7889ed13a3d6788926590273. */
%macro n26_char_grp_to_num_grp(
dsdin=,
grp_vars4sort=,
descending_or_not=,
dsdout=,
num_grp_output_name=,
keep_uniq_rows_by_grp=0
);
/*Note: if keep_uniq_rows_by_grp=1, then only unique grps will be remained in the final dataset*/
%let nvars=%n26_numargs(&grp_vars4sort);
*Use key instead of by in the proc sort, as unknown error occurred when using by with descending function;
*Note: if &dsdin and &dsdout are the same, the final &dsdout will only contain unique rows by keys;
*This would be wrong if wanting to keep all rows!;
*So only use the temporary table dsdout here;
%if &descending_or_not %then %do;
proc sort data=&dsdin nodupkeys out=dsdout;
key &grp_vars4sort /descending;
run;
%end;
%else %do;
proc sort data=&dsdin nodupkeys out=dsdout;
key &grp_vars4sort;
run;
%end;

data dsdout;
set dsdout;
&num_grp_output_name=_n_;
%if &nvars>=1 %then %do;
grps_output_key=catx(':', of &grp_vars4sort);
%end;
run;
/*Only unique grp keys are kept in the above output dsd!*/

%if %eval(&keep_uniq_rows_by_grp=0) %then %do;
*Now add the num_grp_output_name back to the original table;
data tmp;
set &dsdin;
_grps_output_key_=catx(':', of &grp_vars4sort);
run;
proc sql;
create table &dsdout(drop=_grps_output_key_) as
select b.*,a.&num_grp_output_name,a.grps_output_key
from dsdout as a
right join
tmp as b
on a.grps_output_key=b._grps_output_key_;
%end;
%else %do;
data &dsdout;
set dsdout;
run;
%end;
%mend;
