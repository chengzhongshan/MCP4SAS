/* New workflow V6054; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6054i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=25.13;output;
gene='gene01';tissue='c2';expression=24.2;output;
gene='gene01';tissue='c4';expression=67.33999999999999;output;
gene='gene01';tissue='c5';expression=10.41;output;
gene='gene01';tissue='c6';expression=19.48;output;
gene='gene02';tissue='c1';expression=1.26;output;
gene='gene02';tissue='c3';expression=11.4;output;
gene='gene02';tissue='c4';expression=15.47;output;
gene='gene02';tissue='c5';expression=10.54;output;
gene='gene03';tissue='c2';expression=-2.54;output;
gene='gene03';tissue='c3';expression=-4.470000000000001;output;
gene='gene03';tissue='c4';expression=54.6;output;
gene='gene03';tissue='c6';expression=67.74;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6054i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6054o,outdir4matrix=);
data v6054m(keep=metric value);set v6054o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6054m;set v6054m;format value best32.;run;
proc export data=v6054m outfile="%sysfunc(pathname(work))/V6054.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6054;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6054:;quit;
