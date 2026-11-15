/* Test-only namespaced definition from ApplyFunc_rowwide.sas; original SHA256 a3522054ae6051adc3c1d8de444d36104d41e201086e2c73019621e0c4df0f4b. */
%macro n26_ApplyFunc_rowwide(
/*The macro is a handy tool to calculate common summary statistics, such as mean, median, sum, n, std, and others that allowed
in proc sql when conducting analysis on groups on ROW-WIDE. Additionally, the macro can generate summary statistics by 
including data from both rows and columns, with special case to generate summary statistics on all columns without providing row_keys or 
on all data in a table from all columns and rows!*/
dsdin,
row_keys,
KeyVar4dsdout,
Regex4col_vars2apply,
SQL_Fun4apply,
dsdout,
KeyVar4dsdout_length=200,
AlsoAppFun4Cols=0
);
%let n=%n26_numargs(&row_keys);
%put macro var row_keys are &row_keys;

%if %eval(&n=0) %then %do;
data &dsdout;
set &dsdin;
&KeyVar4dsdout="AllRows";
run;
%end;
%else %do;
data &dsdout;
length &KeyVar4dsdout $ &KeyVar4dsdout_length;
set &dsdin;
&KeyVar4dsdout=catx(":",
%let i=1;
%do %while (&i<&n);
   %scan(&row_keys,&i,%str( )),
   %let i=%eval(&i+1);
%end;
   %scan(&row_keys,&n,%str( ))
);
run;
%end;


proc contents data=&dsdin out=_vars_ noprint;
run;
proc sql noprint;
select Name into: vars4apply separated by ' '
from _vars_
where prxmatch("/&Regex4col_vars2apply/i",Name);

select count(Name) into: nvars4apply
from _vars_
where prxmatch("/&Regex4col_vars2apply/i",Name);


%if %eval(&AlsoAppFun4Cols=0) %then %do;
proc sql;
create table &dsdout as
select &KeyVar4dsdout,
  %let ii=1;
  %do %while (&ii<&nvars4apply);
   %let Var=%scan(&vars4apply,&ii,%str( ));
   %str(&SQL_Fun4apply(&Var) as New_&Var,)
   %let ii=%eval(&ii+1);
  %end;
   %let Var=%scan(&vars4apply,&ii,%str( ));
   %str(&SQL_Fun4apply(&Var) as New_&Var)
from &dsdout 
group by &KeyVar4dsdout
order by &KeyVar4dsdout;
%end;

%else %if %eval(&AlsoAppFun4Cols=1) %then %do;
proc sql;
create table &dsdout as
select &KeyVar4dsdout,
  %let ii=1;
  %let Var=&SQL_Fun4apply(;
  %do %while (&ii<&nvars4apply);
   %let Var=&Var%scan(&vars4apply,&ii,%str( )),;
   %let ii=%eval(&ii+1);
  %end;
   %let Var=&Var%scan(&vars4apply,&ii,%str( ));
   %str(&Var%) as ALL_Matched_Cols)
from &dsdout 
group by &KeyVar4dsdout
order by &KeyVar4dsdout;

/*Assemble all dup &KeyVar4dsdout for &SQL_Fun4apply*/
proc sql;
create table &dsdout as
select &KeyVar4dsdout,&SQL_Fun4apply(All_Matched_Cols) as &SQL_Fun4apply
from &dsdout
group by &KeyVar4dsdout;

%end;

*Only remove 'New_' within varnames;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.&dsdout,Rgx=New_);

%mend;
