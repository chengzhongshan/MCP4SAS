define statgraph MGXOncoTemplate;
  begingraph;
    discreteattrmap name='oncocolors';
      value 'No variant detected' / fillattrs=(color=CXEEF0F2) lineattrs=(color=CXEEF0F2);
      value 'Not assessable' / fillattrs=(color=CXA2A9B0) lineattrs=(color=CXA2A9B0);
      value 'Missense' / fillattrs=(color=CX0072B2) lineattrs=(color=CX0072B2);
      value 'Truncating' / fillattrs=(color=CXD55E00) lineattrs=(color=CXD55E00);
      value 'Splice' / fillattrs=(color=CXAA4499) lineattrs=(color=CXAA4499);
      value 'Inframe' / fillattrs=(color=CXE69F00) lineattrs=(color=CXE69F00);
    enddiscreteattrmap;
    discreteattrvar attrvar=background_color var=background_class attrmap='oncocolors';
    discreteattrvar attrvar=event_color var=event_class attrmap='oncocolors';
    %include "&outdir/&prefix._cohorts.sas";
    discreteattrvar attrvar=cohortclass var=cohort attrmap='cohortcolors';
    layout lattice / rows=3 columns=2 rowweights=(.18 .06 .76)
      columnweights=(.73 .27) rowgutter=3 columngutter=8
      columndatarange=union rowdatarange=union;
      sidebar / align=bottom;
        layout gridded / rows=2;
          discretelegend 'events' 'background' / across=3
            exclude=(' ') valueattrs=(size=10) border=false;
          discretelegend 'cohort' / title='Cohort' titleattrs=(size=10 weight=normal) across=2
            exclude=(' ') valueattrs=(size=10) border=false;
        endlayout;
      endsidebar;
      columnaxes;
        columnaxis / display=(tickvalues) tickvalueattrs=(size=10)
          offsetmin=0 offsetmax=0
          linearopts=(viewmin=.5 viewmax=%sysevalf(&ns+.5) tickvalueformat=mgxsample.
            tickvaluelist=(&sample_ticks));
        columnaxis / label='Frequency (%)' labelattrs=(size=10)
          tickvalueattrs=(size=10) offsetmin=0 offsetmax=0
          linearopts=(viewmin=0 viewmax=130 tickvaluelist=(0 50 100));
      endcolumnaxes;
      rowaxes;
        rowaxis / label='Events' labelattrs=(size=10)
          tickvalueattrs=(size=10) offsetmin=0 offsetmax=.03
          linearopts=(viewmin=0 viewmax=&maxburden tickvaluelist=(0 &maxburden));
        rowaxis / display=none offsetmin=0 offsetmax=0
          linearopts=(viewmin=.5 viewmax=1.5);
        rowaxis / display=(tickvalues) tickvalueattrs=(size=10 style=italic)
          offsetmin=0 offsetmax=0
          linearopts=(viewmin=.5 viewmax=%sysevalf(&ng+.5) tickvalueformat=mgxgene.
            tickvaluelist=(&gene_ticks));
      endrowaxes;
      layout overlay / walldisplay=none;
        highlowplot x=burden_x low=burden_zero high=n_events /
          type=line group=cohortclass highcap=none lowcap=none
          lineattrs=(thickness=&summary_thickness.px pattern=solid);
      endlayout;
      layout gridded;
        entry 'Positive / assessable' / textattrs=(size=9);
      endlayout;
      layout overlay / walldisplay=none;
        heatmapparm x=cohort_x y=strip_y colorgroup=cohortclass /
          xbinaxis=false ybinaxis=false display=(fill) name='cohort';
      endlayout;
      layout gridded;entry ' ';endlayout;
      layout overlay / walldisplay=none;
        heatmapparm x=sample_index y=tile_y colorgroup=background_color /
          xbinaxis=false ybinaxis=false display=all
          outlineattrs=(color=white thickness=.6) name='background';
        highlowplot x=event_x low=glyph_low high=glyph_high /
          type=bar barwidth=.86 group=event_color
          lineattrs=(thickness=.1) name='events';
      endlayout;
      layout overlay / walldisplay=none;
        highlowplot y=freq_y low=zero high=pct_mutated /
          highcap=none lowcap=none lineattrs=(color=&gene_summary_color thickness=&summary_thickness.px);
        textplot x=label_x y=freq_y text=count_label / position=right
          textattrs=(size=10);
      endlayout;
    endlayout;
  endgraph;
  end;