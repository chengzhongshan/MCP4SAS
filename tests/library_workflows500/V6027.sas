/* New workflow V6027; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6027i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=-16.87;output;
gene='gene01';tissue='c3';expression=-0.73;output;
gene='gene01';tissue='c4';expression=7.34;output;
gene='gene02';tissue='c2';expression=9.33;output;
gene='gene02';tissue='c3';expression=60.4;output;
gene='gene02';tissue='c4';expression=27.470000000000002;output;
gene='gene03';tissue='c1';expression=1.3900000000000001;output;
gene='gene03';tissue='c2';expression=65.46;output;
gene='gene03';tissue='c3';expression=-17.47;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6027i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6027o,outdir4matrix=);
data v6027m(keep=metric value);set v6027o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6027m;set v6027m;format value best32.;run;
proc export data=v6027m outfile="%sysfunc(pathname(work))/V6027.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6027;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6027:;quit;
