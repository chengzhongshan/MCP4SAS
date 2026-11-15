/* New workflow V6051; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6051i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=32.13;output;
gene='gene01';tissue='c3';expression=51.27;output;
gene='gene02';tissue='c2';expression=38.33;output;
gene='gene02';tissue='c3';expression=44.4;output;
gene='gene03';tissue='c1';expression=45.39;output;
gene='gene03';tissue='c2';expression=49.46;output;
gene='gene03';tissue='c3';expression=-15.469999999999999;output;
gene='gene04';tissue='c1';expression=34.52;output;
gene='gene04';tissue='c2';expression=-10.41;output;
gene='gene05';tissue='c1';expression=26.65;output;
gene='gene05';tissue='c3';expression=35.79;output;
gene='gene06';tissue='c2';expression=-23.15;output;
gene='gene06';tissue='c3';expression=63.92;output;
gene='gene07';tissue='c1';expression=56.91;output;
gene='gene07';tissue='c2';expression=59.98;output;
gene='gene07';tissue='c3';expression=38.05;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6051i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6051o,outdir4matrix=);
data v6051m(keep=metric value);set v6051o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6051m;set v6051m;format value best32.;run;
proc export data=v6051m outfile="%sysfunc(pathname(work))/V6051.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6051;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6051:;quit;
