package SAS_Source_Analysis;
use strict;
use warnings;

# Macro quoting is a separate lexical context: apostrophes may be unmatched,
# and %(/%)/%' encode literal delimiters rather than SAS source syntax.
sub _macro_quote_span {
    my ($text,$offset)=@_;
    return unless substr($text,$offset) =~ /^%(str|nrstr|quote|nrquote|bquote|nrbquote|superq)\b\s*\(/i;
    my ($name,$header)=(lc($1),$&);
    my $body=$offset+length($header);
    my ($i,$depth)=($body,1);
    my @children;
    my $len=length($text);
    while ($i<$len) {
        my $ch=substr($text,$i,1);
        if ($ch eq '%' && substr($text,$i+1,1) =~ /^[()'"]$/) { $i+=2; next; }
        if ($ch eq '%' && (my $child=_macro_quote_span($text,$i))) {
            push @children,$child;
            $i=$child->{end}; next;
        }
        $depth++ if $ch eq '(';
        if ($ch eq ')') {
            $depth--;
            return {name=>$name,start=>$offset,body=>$body,end=>$i+1,closed=>1,children=>\@children} if $depth==0;
        }
        $i++;
    }
    return {name=>$name,start=>$offset,body=>$body,end=>$len,closed=>0,children=>\@children};
}

sub _macro_quote_spans {
    my ($span)=@_;
    return ($span,map {_macro_quote_spans($_)} @{$span->{children}||[]});
}

# Mask raw inline records, preserving character offsets and newlines for
# preflight context. Locate declarations lexically, outside strings/comments.
sub analyze_inline_data {
    my ($text) = @_;
    $text //= '';
    my $masked = $text;
    my @unclosed;
    my ($i, $quote, $block, $comment, $statement_start) = (0, '', 0, 0, 1);
    my $len = length($text);
    while ($i < $len) {
        my $ch = substr($text, $i, 1);
        my $pair = substr($text, $i, 2);
        if ($block) {
            if ($pair eq '*/') { $block=0; $i+=2; } else { $i++; }
            next;
        }
        if ($comment) {
            $comment=0 if $ch eq ';';
            $i++; next;
        }
        if (length $quote) {
            if ($ch eq $quote) {
                if (substr($text, $i+1, 1) eq $quote) { $i+=2; next; }
                $quote='';
            }
            $i++; next;
        }
        if ($pair eq '/*') { $block=1; $i+=2; next; }
        if ($pair eq '%*') { $comment=1; $i+=2; next; }
        if ($ch eq '*' && $statement_start) { $comment=1; $i++; next; }
        if ($ch eq '%' && (my $span=_macro_quote_span($text,$i))) {
            $i=$span->{end}; $statement_start=0; next;
        }
        if ($ch eq "'" || $ch eq '"') { $quote=$ch; $statement_start=0; $i++; next; }
        if ($ch =~ /\s/) { $i++; next; }
        if ($ch eq ';') { $statement_start=1; $i++; next; }
        if ($statement_start && substr($text, $i) =~ /^(datalines4?|cards4?|parmcards4?)\s*;/i) {
            my ($keyword, $declaration) = ($1, $&);
            my $header_end = $i + length($declaration);
            my $newline = index($text, "\n", $header_end);
            my $header_line_end = $newline >= 0 ? $newline : $len;
            # Invalid same-line records remain visible to the inline-card check.
            if (substr($text, $header_end, $header_line_end-$header_end) !~ /\S/) {
                my $start = $newline >= 0 ? $newline+1 : $len;
                my $cursor = $start;
                my $terminator = $keyword =~ /4$/ ? qr/^\s*;;;;/ : qr/^\s*;/;
                my $found=0;
                while ($cursor < $len) {
                    my $end = index($text, "\n", $cursor);
                    $end=$len if $end<0;
                    if (substr($text, $cursor, $end-$cursor) =~ $terminator) { $found=1; last; }
                    $cursor=$end<$len ? $end+1 : $len;
                }
                my $raw = substr($masked, $start, $cursor-$start);
                $raw =~ s/[^\n\r]/ /g;
                substr($masked, $start, $cursor-$start, $raw);
                if (!$found) {
                    my $prefix=substr($text, 0, $i);
                    push @unclosed, {line=>1+($prefix =~ tr/\n//), keyword=>uc($keyword)};
                }
                $i=$cursor;
                $statement_start=1;
                next;
            }
        }
        $statement_start=0;
        $i++;
    }
    return {masked=>$masked, unclosed=>\@unclosed};
}

sub mask_inline_data { return analyze_inline_data($_[0])->{masked}; }

# Analyze syntax once in source order. Regex removal of comments before
# strings confuses literal '/*' with an actual comment opener.
sub analyze_source {
    my ($text) = @_;
    $text //= '';
    my $inline=analyze_inline_data($text);
    my $scan=$inline->{masked};
    my ($masked,$comments_masked)=($scan,$scan);
    my $last_line=1+($text =~ tr/\n//);
    my @findings=map {
        +{type=>'unclosed_inline_data',line=>$_->{line},
          message=>"Inline data declaration $_->{keyword} is missing its terminating line",
          context_ref=>[($_->{line}-1)..$last_line]}
    } @{$inline->{unclosed}};
    my (@macro_quotes,@single_quotes);
    my $quote_start=0;
    my ($i,$line,$quote,$block,$comment,$statement_start,$start_line)=(0,1,'',0,0,1,0);
    my $comment_start_state=1;
    my $len=length($scan);
    my $blank=sub {
        my ($offset,$count,$comments)=@_;
        my $chunk=substr($scan,$offset,$count);
        $chunk =~ s/[^\r\n]/ /g;
        substr($masked,$offset,$count,$chunk);
        substr($comments_masked,$offset,$count,$chunk) if $comments;
    };
    while ($i<$len) {
        my $ch=substr($scan,$i,1);
        my $pair=substr($scan,$i,2);
        if ($block) {
            if ($pair eq '*/') { $blank->($i,2,1); $block=0; $i+=2; next; }
            $blank->($i,1,1); $line++ if $ch eq "\n"; $i++; next;
        }
        if ($comment) {
            $blank->($i,1,1);
            if ($ch eq ';') { $comment=0; $statement_start=$comment_start_state; }
            $line++ if $ch eq "\n"; $i++; next;
        }
        if (length $quote) {
            if ($ch eq $quote && substr($scan,$i+1,1) eq $quote) {
                $blank->($i,2,0); $i+=2; next;
            }
            # SAS evaluates macro functions inside double-quoted strings.
            # Escaped delimiters must not close the surrounding string.
            if ($quote eq '"' && $ch eq '%' && (my $span=_macro_quote_span($scan,$i))) {
                push @macro_quotes,_macro_quote_spans($span);
                my $chunk=substr($scan,$i,$span->{end}-$i);
                $line+=($chunk =~ tr/\n//);
                $blank->($i,$span->{end}-$i,0);
                $i=$span->{end}; next;
            }
            $blank->($i,1,0);
            if ($ch eq $quote) {
                push @single_quotes,{start=>$quote_start,end=>$i+1} if $quote eq "'";
                $quote='';
            }
            $line++ if $ch eq "\n"; $i++; next;
        }
        if ($pair eq '/*') { $start_line=$line; $block=1; $blank->($i,2,1); $i+=2; next; }
        if ($pair eq '*/') {
            push @findings,{type=>'unexpected_comment_close',line=>$line,
                message=>"Unexpected closing block comment '*/'",context_ref=>[($line-2)..($line+2)]};
            $i+=2; $statement_start=0; next;
        }
        if ($pair eq '%*') { $comment_start_state=$statement_start; $comment=1; $blank->($i,2,1); $i+=2; next; }
        if ($ch eq '*' && $statement_start) { $comment_start_state=1; $comment=1; $blank->($i,1,1); $i++; next; }
        if ($ch eq '%' && (my $span=_macro_quote_span($scan,$i))) {
            push @macro_quotes,_macro_quote_spans($span);
            if (!$span->{closed}) {
                push @findings,{type=>'unclosed_macro_invocation',line=>$line,
                    message=>"Macro quoting function %$span->{name}( is missing its closing ')'",
                    context_ref=>[($line-2)..$last_line]};
            }
            my $chunk=substr($scan,$i,$span->{end}-$i);
            $line+=($chunk =~ tr/\n//);
            $blank->($i,$span->{end}-$i,0);
            $i=$span->{end}; $statement_start=0; next;
        }
        if ($ch eq "'" || $ch eq '"') {
            $quote=$ch; $quote_start=$i; $start_line=$line; $statement_start=0; $blank->($i,1,0); $i++; next;
        }
        if ($ch eq "\n") { $line++; $i++; next; }
        if ($ch =~ /\s/) { $i++; next; }
        $statement_start=$ch eq ';' ? 1 : 0;
        $i++;
    }
    if ($block || length $quote) {
        my $type=$block ? 'unclosed_block_comment' : $quote eq "'" ? 'unclosed_single_quote' : 'unclosed_double_quote';
        my $description=$block ? 'block comment' : $quote eq "'" ? 'single-quoted string' : 'double-quoted string';
        push @findings,{type=>$type,line=>$start_line,
            message=>"Unclosed $description starting on line $start_line",
            context_ref=>[($start_line-2)..$last_line]};
    }
    return {masked=>$masked,comments_masked=>$comments_masked,findings=>\@findings,macro_quotes=>\@macro_quotes,single_quotes=>\@single_quotes};
}

sub mask_noncode { return analyze_source($_[0])->{masked}; }
sub mask_comments { return analyze_source($_[0])->{comments_masked}; }
sub mask_macro_literals {
    my ($text)=@_;
    $text //= '';
    my $analysis=analyze_source($text);
    my $masked=$analysis->{comments_masked};
    for my $span (@{$analysis->{macro_quotes}}) {
        # NRSTR masks percent/ampersand at compilation. Other quote functions
        # may evaluate nested calls first, so their real dependencies remain.
        next unless $span->{name} eq 'nrstr';
        my $length=$span->{end}-$span->{body}-($span->{closed}?1:0);
        my $body=substr($masked,$span->{body},$length);
        $body =~ s/[^\r\n]/ /g;
        substr($masked,$span->{body},$length,$body);
    }
    return $masked;
}
sub _literal_is_executable {
    my ($analysis,$span)=@_;
    my $prefix=substr($analysis->{masked},0,$span->{start});
    my @stack;
    while ($prefix =~ /\b(call\s+execute|dosubl)\s*\(|([()])/ig) {
        if (defined $1) {push @stack,1;}
        elsif ($2 eq '(') {push @stack,0;}
        else {pop @stack;}
    }
    return scalar grep {$_} @stack;
}
sub macro_dependency_view {
    my ($text)=@_;
    $text //= '';
    my $analysis=analyze_source($text);
    my $masked=mask_macro_literals($text);
    for my $span (@{$analysis->{single_quotes}}) {
        # Literal code passed to these execution APIs is a real dependency.
        if (_literal_is_executable($analysis,$span)) {
            my $body=substr($text,$span->{start}+1,$span->{end}-$span->{start}-2);
            my ($decoded,@positions)=('');
            for (my $pos=0;$pos<length($body);) {
                my $size=substr($body,$pos,2) eq "''" ? 2 : 1;
                push @positions,[$pos,$size];
                $decoded.=substr($body,$pos,1);
                $pos+=$size;
            }
            my $view=macro_dependency_view($decoded);
            for my $idx (0..$#positions) {
                next if substr($view,$idx,1) eq substr($decoded,$idx,1);
                my ($pos,$size)=@{$positions[$idx]};
                my $blank=substr($body,$pos,$size); $blank =~ s/[^\r\n]/ /g;
                substr($masked,$span->{start}+1+$pos,$size,$blank);
            }
            next;
        }
        my $length=$span->{end}-$span->{start};
        my $literal=substr($masked,$span->{start},$length);
        $literal =~ s/[^\r\n]/ /g;
        substr($masked,$span->{start},$length,$literal);
    }
    return $masked;
}
sub include_targets {
    my ($text)=@_;
    $text //= '';
    my $active=macro_dependency_view($text);
    my $paths=mask_comments($text);
    my @targets;
    my $analysis=analyze_source($text);
    my @deferred;
    for my $span (@{$analysis->{single_quotes}}) {
        next unless _literal_is_executable($analysis,$span);
        push @deferred,$span;
        my $body=substr($text,$span->{start}+1,$span->{end}-$span->{start}-2);
        $body =~ s/''/'/g;
        push @targets,@{include_targets($body)};
    }
    while ($active =~ /%include\b/ig) {
        my $offset=$-[0];
        next if grep {$offset>=$_->{start} && $offset<$_->{end}} @deferred;
        my $tail=substr($paths,$offset);
        next unless $tail =~ /^%include\s+/i;
        my $pos=$+[0];
        # A statement can name several quoted files. Stop at an option,
        # statement boundary or nonliteral operand, never a later statement.
        while ($pos<length($tail)) {
            $pos++ while $pos<length($tail) && substr($tail,$pos,1) =~ /\s/;
            my $quote=substr($tail,$pos,1);
            last unless $quote eq "'" || $quote eq '"';
            ++$pos;
            my ($value,$closed)=('',0);
            while ($pos<length($tail)) {
                my $char=substr($tail,$pos++,1);
                if ($char eq $quote) {
                    if (substr($tail,$pos,1) eq $quote) {$value.=$quote; $pos++; next;}
                    $closed=1;
                    last;
                }
                $value.=$char;
            }
            last unless $closed;
            push @targets,$value if length $value;
        }
    }
    return \@targets;
}
sub format_name_issues {
    my ($text)=@_;
    my $masked=mask_noncode($text);
    my @issues;
    while ($masked =~ /\bproc\s+format\b[^;]*;(.*?)\b(?:run|quit)\s*;/igs) {
        my ($body,$offset)=($1,$-[1]);
        while ($body =~ /\b(value|invalue|picture)\s+\$?([A-Za-z_]\w*)\b/ig) {
            my ($kind,$name,$start)=(lc($1),$2,$-[2]);
            next unless $name =~ /\d$/;
            my $prefix=substr($masked,0,$offset+$start);
            my $line=1+($prefix =~ tr/\n//);
            push @issues,{type=>'invalid_literal_format_name',line=>$line,
                message=>"Literal $kind name '$name' ends in a digit; SAS format/informat names must end in a nondigit. Use a letter suffix.",
                context_ref=>[$line]};
        }
    }
    # Advisory only: macro-generated or conditional definitions may differ
    # at execution. SAS runtime diagnostics still determine failure status.
    return \@issues;
}
sub fileref_name_issues {
    my ($text)=@_;
    my $masked=mask_noncode($text);
    my @issues;
    while ($masked =~ /\bfilename\s+([A-Za-z_]\w*)\b/ig) {
        my ($name,$offset)=($1,$-[1]);
        next unless length($name)>8;
        my $prefix=substr($masked,0,$offset);
        my $line=1+($prefix =~ tr/\n//);
        push @issues,{type=>'invalid_literal_fileref_name',line=>$line,
            message=>"Literal fileref '$name' exceeds the SAS limit of 8 characters; choose a shorter fileref.",
            context_ref=>[$line]};
    }
    return \@issues;
}
1;
