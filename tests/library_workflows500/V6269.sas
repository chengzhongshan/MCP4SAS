/* New workflow V6269; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6269i;
length gene $80;
gene='allele01';ref=38;alt=6;output;
gene='allele02';ref=22;alt=36;output;
gene='allele03';ref=6;alt=11;output;
gene='allele04';ref=5;alt=26;output;
gene='allele05';ref=27;alt=18;output;
run;
%n26_calculate_binomial_P(dsdin=v6269i,dsdout=v6269o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=2);
data v6269m(keep=metric value);set v6269o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6269m;set v6269m;format value best32.;run;
proc export data=v6269m outfile="%sysfunc(pathname(work))/V6269.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6269;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6269:;quit;
