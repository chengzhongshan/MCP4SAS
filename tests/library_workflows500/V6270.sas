/* New workflow V6270; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6270i;
length gene $80;
gene='allele01';ref=14;alt=9;output;
gene='allele02';ref=4;alt=19;output;
gene='allele03';ref=10;alt=31;output;
gene='allele04';ref=8;alt=33;output;
gene='allele05';ref=38;alt=8;output;
gene='allele06';ref=11;alt=10;output;
run;
%n26_calculate_binomial_P(dsdin=v6270i,dsdout=v6270o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=3);
data v6270m(keep=metric value);set v6270o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6270m;set v6270m;format value best32.;run;
proc export data=v6270m outfile="%sysfunc(pathname(work))/V6270.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6270;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6270:;quit;
