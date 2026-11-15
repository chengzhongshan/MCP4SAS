/* Test-only namespaced definition from Zscore4matrix.sas; original SHA256 06211980a634bb5f457840e433a78beff11667c12b8dfc79bb10e598d5196d7a. */
%macro n26_Zscore4matrix(dsdin
,rowwide
,ByVar4rowwide
,dsdout
);

%if %eval(&rowwide=0) %then %do;
/*colwide z-score*/
proc standard data=&dsdin mean=0 std=1 out=&dsdout;
var _numeric_;
run;
%end;
%else %do;
/*row-wide z-score*/
proc transpose data=&dsdin out=&dsdin._tmp;
var _numeric_;
by &ByVar4rowwide notsorted;
run;
proc standard data=&dsdin._tmp mean=0 std=1 out=rowwide_z;
var col1;
by &ByVar4rowwide notsorted;
run;
%n26_longdsd2matlabmatrix(dsd=rowwide_z
                     ,var_row=&ByVar4rowwide
                     ,var_col=_NAME_
                     ,data_var=col1
                     ,value2asign4missing=-999
					 ,dsdout=&dsdout
                     ,outdir4matrix=);
%end;
%mend;
