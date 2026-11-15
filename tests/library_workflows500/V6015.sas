/* New workflow V6015; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6015i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=42.13;output;
gene='gene01';tissue='c2';expression=-23.8;output;
gene='gene02';tissue='c1';expression=59.26;output;
gene='gene02';tissue='c2';expression=42.33;output;
gene='gene03';tissue='c1';expression=-7.61;output;
gene='gene03';tissue='c2';expression=43.46;output;
gene='gene04';tissue='c1';expression=8.52;output;
gene='gene04';tissue='c2';expression=-1.41;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6015i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6015o,outdir4matrix=);
data v6015m(keep=metric value);set v6015o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6015m;set v6015m;format value best32.;run;
proc export data=v6015m outfile="%sysfunc(pathname(work))/V6015.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6015;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6015:;quit;
