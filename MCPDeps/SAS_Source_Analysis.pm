package SAS_Source_Analysis;
use strict;
use warnings;

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
            $blank->($i,1,0);
            $quote='' if $ch eq $quote;
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
        if ($ch eq "'" || $ch eq '"') {
            $quote=$ch; $start_line=$line; $statement_start=0; $blank->($i,1,0); $i++; next;
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
    return {masked=>$masked,comments_masked=>$comments_masked,findings=>\@findings};
}

sub mask_noncode { return analyze_source($_[0])->{masked}; }
sub mask_comments { return analyze_source($_[0])->{comments_masked}; }
1;
