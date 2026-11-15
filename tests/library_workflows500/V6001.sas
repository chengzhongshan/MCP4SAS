/* New workflow V6001; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6001i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=29.13;output;
gene='gene01';tissue='c2';expression=20.2;output;
gene='gene01';tissue='c3';expression=55.27;output;
gene='gene02';tissue='c1';expression=27.26;output;
gene='gene02';tissue='c2';expression=-25.669999999999998;output;
gene='gene02';tissue='c3';expression=31.400000000000002;output;
gene='gene03';tissue='c1';expression=25.39;output;
gene='gene03';tissue='c2';expression=-25.54;output;
gene='gene03';tissue='c3';expression=56.53;output;
gene='gene04';tissue='c1';expression=-19.48;output;
gene='gene04';tissue='c2';expression=-28.41;output;
gene='gene04';tissue='c3';expression=48.660000000000004;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6001i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6001o,outdir4matrix=);
data v6001m(keep=metric value);set v6001o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6001m;set v6001m;format value best32.;run;
proc export data=v6001m outfile="%sysfunc(pathname(work))/V6001.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6001;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6001:;quit;
