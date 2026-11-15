/* New workflow V6047; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6047i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=49.13;output;
gene='gene01';tissue='c3';expression=39.27;output;
gene='gene01';tissue='c4';expression=-25.66;output;
gene='gene02';tissue='c2';expression=3.3299999999999996;output;
gene='gene02';tissue='c3';expression=-2.6;output;
gene='gene02';tissue='c4';expression=-24.529999999999998;output;
gene='gene03';tissue='c1';expression=54.39;output;
gene='gene03';tissue='c2';expression=11.46;output;
gene='gene03';tissue='c3';expression=-3.4699999999999998;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6047i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6047o,outdir4matrix=);
data v6047m(keep=metric value);set v6047o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6047m;set v6047m;format value best32.;run;
proc export data=v6047m outfile="%sysfunc(pathname(work))/V6047.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6047;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6047:;quit;
