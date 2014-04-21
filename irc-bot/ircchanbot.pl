#!/usr/bin/env perl

use strict;
use warnings;
use IO::Socket;
use POSIX qw(strftime);

my $user="pff-icb";
my $nick=shift || "pff-icb";
my $server="chat.freenode.net";
my $port=6667;
my @channel=qw(kalamangga.net);

$SIG{INT} = \&quit_h;
$SIG{TERM} = \&quit_h;

connect_h();
while (my $input = <$sock>) {
	chomp $input;
	if ($input =~ /^PING\s*:(.*?)$/i) {
		add_time("PING from $1");
		$sock->print("PONG $1\n");
		add_time("PONG $1");;
	} elsif ($input =~ /^:(.*?)\!(.*?)\s+(.*?)\s+(.*?)\s+:(.*?)$/i) {
		add_time("{$3} $1 [$2] @ $4 : $5");
	} else {
		add_time($input);;
	};
};

sub connect_h {
	print "Connecting to server : $server ";
	my $sock = IO::Socket::INET->new(PeerAddr=>$server,PeerPort=>$port,Proto=>'tcp')
		or die "[error] $!\n";
	print "[connected]\n";
	$sock->print("USER $user $user $user $user\n");
	$sock->print("NICK $nick\n");
	for my $channel (@channel) {
		$sock->print("JOIN #$channel\n");
	};
};
sub quit_h {
	add_time("$!");
	close $sock;
	add_time("Disconnected from $server");
};
sub add_time {
	my ($str) = @_;
	chomp($str);
	my $time_str = strftime "%Y%m%d%H%M%S", localtime;
	print "$time_str - $str\n";
	save_log("$time_str - $str\n");
};
sub save_log {
	my($logs) = @_;
	open LOG, ">> ircchanbot.log" or die "$!\n";
	print LOG $logs;
	close LOG;
};
