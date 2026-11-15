/* New workflow V6301; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6301i;
length gene $80 c1 $80 c2 $80 c3 $80;
gene='gene01';c1='19.13';c2='-11.799999999999999';c3='-10.729999999999999';output;
gene='gene02';c1='30.26';c2='17.330000000000002';c3='57.4';output;
gene='gene03';c1='-20.61';c2='48.46';c3='40.53';output;
gene='gene04';c1='35.52';c2='-26.41';c3='-19.34';output;
run;
%n26_char2num_dsd(dsdin=v6301i,vars=c1,dsdout=v6301o);
data v6301m(keep=metric value);set v6301o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6301m;set v6301m;format value best32.;run;
proc export data=v6301m outfile="%sysfunc(pathname(work))/V6301.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6301;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6301:;quit;
