/* New workflow V6062; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6062i;
length gene $80;
gene='gene01';c1=-5.87;c2=34.2;c3=42.27;c4=61.34;output;
gene='gene02';c1=66.26;c2=39.33;c3=69.4;c4=49.47;output;
gene='gene03';c1=9.39;c2=-11.54;c3=28.53;c4=-28.4;output;
gene='gene04';c1=-5.48;c2=-24.41;c3=63.660000000000004;c4=0.73;output;
gene='gene05';c1=16.65;c2=-8.28;c3=58.79;c4=28.86;output;
run;
%n26_Zscore4matrix(dsdin=v6062i,rowwide=0,ByVar4rowwide=gene,dsdout=v6062o);
data v6062m(keep=metric value);set v6062o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6062m;set v6062m;format value best32.;run;
proc export data=v6062m outfile="%sysfunc(pathname(work))/V6062.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6062;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6062:;quit;
