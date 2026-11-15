/* New workflow V6045; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6045i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=-28.87;output;
gene='gene01';tissue='c2';expression=-17.8;output;
gene='gene02';tissue='c1';expression=7.26;output;
gene='gene02';tissue='c2';expression=15.33;output;
gene='gene03';tissue='c1';expression=16.39;output;
gene='gene04';tissue='c2';expression=30.59;output;
gene='gene05';tissue='c1';expression=57.65;output;
gene='gene05';tissue='c2';expression=-6.279999999999999;output;
gene='gene06';tissue='c1';expression=27.78;output;
gene='gene06';tissue='c2';expression=55.85;output;
gene='gene07';tissue='c1';expression=-9.09;output;
gene='gene08';tissue='c2';expression=53.11;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6045i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6045o,outdir4matrix=);
data v6045m(keep=metric value);set v6045o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6045m;set v6045m;format value best32.;run;
proc export data=v6045m outfile="%sysfunc(pathname(work))/V6045.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6045;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6045:;quit;
