#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use 5.010;
use DDP;
use Carp;
use File::Slurp;
use Perl6::Form;
use Encode;
use utf8;

sub get_words {
    my ($file) = @_;

    my %words;
    my $content = read_file($file);

    Encode::_utf8_on($content);

    foreach my $word (split /\s+/, $content) {

        my $normalized_word = get_normilized_word($word);
        next if $normalized_word eq '';

        #warn "$word '$normalized_word'" if $normalized_word !~ /[a-z0-9-]/;

        $words{$normalized_word}++;
    }

    return %words;
}

sub get_normilized_word {
    my ($word) = @_;

    my $normalized_word = lc($word);
    $normalized_word =~ s/["“:,\.\[\]\(\)!\?]//g;
    $normalized_word =~ s/'s//g;
    $normalized_word =~ s/'re//g;
    $normalized_word =~ s/'ve//g;
    $normalized_word =~ s/'t//g;
    $normalized_word =~ s/'ll//g;
    $normalized_word =~ s/'m//g;
    $normalized_word =~ s/'d//g;
    $normalized_word =~ s/^'//g;
    $normalized_word =~ s/'$//g;
    $normalized_word =~ s/_//g;
    $normalized_word =~ s/…//g;

    return $normalized_word;
}

sub output_words {
    my ($opts) = @_;

    croak "Need limit" unless $opts->{limit};

    my $max_words = $opts->{limit};
    my $format = "{>>} {<<<<<<<<<<<<<}{<<<<<}";
    my %words = %{$opts->{words}};

    say "Uniq words count: ", scalar keys %words, "\n";

    print form $format,
        "#", 'word', 'count';

    say '-'x(length($format));

    my $i = 0;
    foreach my $word (sort { $words{$b} <=> $words{$a} } keys %words) {
        $i++;
        print form $format,
            $i, $word, $words{$word};
        last if $i > $max_words - 1;
    }

}

# main
my $file_1 = '/home/bessarabov/Dropbox/chaos/south_park_scripts/101.txt';
my $file_2 = '/home/bessarabov/Dropbox/chaos/south_park_scripts/102.txt';

my %words_1 = get_words($file_1);
my %words_2 = get_words($file_2);

foreach my $word_in_1 (keys %words_1) {
    delete $words_2{$word_in_1};
}

output_words({
    words => \%words_2,
    limit => 10,
});
