#!/usr/bin/env perl -w

use strict;
use XML::RSS;
use LWP::Simple;

my $rssurl = shift || "http://blog.yht.web.id/feed";

my $raw = get($rssurl);
my $rss = new XML::RSS->parse($raw);

foreach my $item (@{$rss->{'items'}}) {
	my $title = $item->{'title'};
	my $link = $item->{'link'};
	my $desc = $item->{'description'};
	print "- $title\n  $link\n  $desc\n\n";
};


