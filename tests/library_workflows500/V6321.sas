/* New workflow V6321; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6321i;
length gene $80 c1 $80 c2 $80 c3 $80;
gene='gene01';c1='6.13';c2='40.2';c3='62.27';output;
gene='gene02';c1='11.26';c2='11.33';c3='11.4';output;
gene='gene03';c1='-22.61';c2='-5.54';c3='-15.469999999999999';output;
gene='gene04';c1='28.52';c2='69.58999999999999';c3='65.66';output;
run;
%n26_char2num_dsd(dsdin=v6321i,vars=c1 c2 c3,dsdout=v6321o);
data v6321m(keep=metric value);set v6321o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6321m;set v6321m;format value best32.;run;
proc export data=v6321m outfile="%sysfunc(pathname(work))/V6321.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6321;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6321:;quit;
