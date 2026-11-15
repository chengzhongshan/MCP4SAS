/* Test-only namespaced definition from AddMissingTag4Grps.sas; original SHA256 b4cb80caea1faa5d8037e2d665dac250f00850c889118c539dcd2ca75a373c68. */
%macro n26_AddMissingTag4Grps(
dsdin=,/*Long format dsd with grp vars and numeric value var*/
grp_vars=, /*Group variables used to stratify numeric variable for missing test;
Note: any numeric variable with missing value in a group will lead to the assigment of 
value 1 to the combination of these grp vars, meanwhile, 0 will be supplied the group vars*/
value_var=,	/*Numeric variable subject to missing evaluation*/
varname4missingtag=mtag,/*variable name used to label the newly created variable indicating
the missing status of numeric variable in each group based on the combination of these grp_vars*/
dsdout=dsdout /*Output a new dsd*/
);
%let grp_vars4sql=%n26_list2sql_by_grps(list=&grp_vars);
proc sql;
create table &dsdout as
select a.*,case when b.&varname4missingtag=1 then 1
                          else 0
                          end as &varname4missingtag
from &dsdin as a
left join
(select *, 1 as &varname4missingtag from &dsdin 
group by &grp_vars4sql 
having &value_var=.) as b
on 
%do gi=1 %to %n26_ntokens(&grp_vars);
  %if &gi>1 %then %do;
		 and a.%scan(&grp_vars,&gi,%str( ))=b.%scan(&grp_vars,&gi,%str( ))
  %end;
  %else %do;
	   a.%scan(&grp_vars,&gi,%str( ))=b.%scan(&grp_vars,&gi,%str( ))
  %end;
%end;
;


%mend;
