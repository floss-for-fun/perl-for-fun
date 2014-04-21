#!/usr/bin/perl -w

use strict;
use Net::IRC;
use POSIX qw(strftime);

my $irc = new Net::IRC;

my $server = $ARGV[0] || 'chat.freenode.net';
my $port = $ARGV[1] || 6667;
my $nick = $ARGV[2] || 'netircbot';
my $uname = 'netircbot';
my $iname = 'Perl Net::IRC bot';
my $chan = '#kalamangga.net';
my $botver = 'perl-net-irc-bot 0.01';

add_time("Connecting to $server...\n");
my $conn = $irc->newconn(Server => $server, Port => $port, Nick => $nick, Ircname => $iname, Username => $uname)
    or die "irctest: Can't connect to IRC server.\n";

sub on_connect {
	my $self = shift;
	add_time("Joining $chan...\n");
	$self->join("$chan");
	$self->privmsg("$chan", "Hi, all");
	$self->topic("$chan");
}
sub on_init {
	my ($self, $event) = @_;
	my (@args) = ($event->args);
	shift (@args);
	add_time("*** @args\n");
}
sub on_part {
	my ($self, $event) = @_;
	my ($channel) = ($event->to)[0];
	add_time("*** $event->nick has left channel $channel\n");
}
sub on_join {
	my ($self, $event) = @_;
	my ($channel) = ($event->to)[0];
	add_time("*** $event->nick ($event->userhost) has joined channel $channel\n");
	$self->privmsg("#$channel", "Welcome back $event->nick");
}
sub on_msg {
	my ($self, $event) = @_;
	my ($nick) = $event->nick;
	add_time("*$nick*  ", ($event->args), "\n");
}
sub on_public {
	my ($self, $event) = @_;
	my @to = $event->to;
	my ($nick, $mynick) = ($event->nick, $self->nick);
	my ($arg) = ($event->args);
	add_time("<$nick> $arg\n");
	if ($arg =~ /$mynick/i) {
		$self->privmsg([ @to ], "Hi, $nick!");
	} elsif ($arg =~ /$mynick\squit\!/i) {
		$self->privmsg([ @to ], "OK, $nick!");
		$self->quit("Yow!!");
		add_time("");
		exit 0;
	} elsif ($arg =~ /ping/i) {
		$self->ctcp_reply($nick, join (' ', ('PING')));
	} elsif ($arg =~ /^chat/i) {
		$self->new_chat(1, $event->nick, $event->host);
	};
};
sub on_umode {
	my ($self, $event) = @_;
	my @to = $event->to;
	my ($nick, $mynick) = ($event->nick, $self->nick);
	my ($arg) = ($event->args);

	print "<$nick> $arg\n";
	if ($arg =~ /$mynick/i) {
		$self->privmsg([ @to ], "Hi, $nick!");
	};
};
sub on_chat {
	my ($self, $event) = @_;
	my ($sock) = ($event->to)[0];
	print '*' . $event->nick . '* ' . join(' ', $event->args), "\n";
	$self->privmsg($sock, "Hi..");
};
sub on_names {
	my ($self, $event) = @_;
	my (@list, $channel) = ($event->args);
	($channel, @list) = splice @list, 2;
	add_time("Users on $channel: @list\n");
};
sub on_ping {
	my ($self, $event) = @_;
	my $nick = $event->nick;
	$self->ctcp_reply($nick, join (' ', ($event->args)));
	add_time("*** CTCP PING request from $nick received\n");
};
sub on_ping_reply {
	my ($self, $event) = @_;
	my ($args) = ($event->args)[1];
	my ($nick) = $event->nick;
	$args = time - $args;
	add_time("*** CTCP PING reply from $nick: $args sec.\n");
};
sub on_nick_taken {
	my ($self) = shift;
	$self->nick($self->nick . "^");
};
sub on_action {
	my ($self, $event) = @_;
	my ($nick, @args) = ($event->nick, $event->args);
	add_time("* $nick @args\n");
};
sub on_disconnect {
	my ($self, $event) = @_;
	add_time("Disconnected from ", $event->from(), " (",
		($event->args())[0], "). Attempting to reconnect...\n");
	$self->connect();
};
sub on_topic {
	my ($self, $event) = @_;
	my @args = $event->args();
	if ($event->type() eq 'notopic') {
		add_time("No topic set for $args[1].\n");
	} elsif ($event->type() eq 'topic' and $event->to()) {
		add_time("Topic change for ", $event->to(), ": $args[0]\n");
	} else {
		add_time("The topic for $args[1] is \"$args[2]\".\n");
	};
};
sub on_version {
    my ($self, $event) = @_;
    my $nick = $event->nick;
    $self->ctcp_reply($nick, join (' ', ($event->args), $botver));
    add_time("*** CTCP VERSION request from $nick received\n");
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
sub blah {
	my ($self, $event) = @_;
	add_time("Got event of type: " . $event->type . "\n");
}

add_time("Installing handler routines...");
$conn->add_handler('cping',  \&on_ping);
$conn->add_handler('cversion',  \&on_version);
$conn->add_handler('crping', \&on_ping_reply);
$conn->add_handler('msg',    \&on_msg);
$conn->add_handler('chat',   \&on_chat);
$conn->add_handler('public', \&on_public);
$conn->add_handler('caction', \&on_action);
$conn->add_handler('join',   \&on_join);
$conn->add_handler('umode',   \&on_umode);
$conn->add_handler('part',   \&on_part);
$conn->add_handler('cdcc',   \&on_dcc);
$conn->add_handler('topic',   \&on_topic);
$conn->add_handler('notopic',   \&on_topic);
$conn->add_global_handler([ 251,252,253,254,302,255 ], \&on_init);
$conn->add_global_handler('disconnect', \&on_disconnect);
$conn->add_global_handler(376, \&on_connect);
$conn->add_global_handler(433, \&on_nick_taken);
$conn->add_global_handler(353, \&on_names);
#$conn->add_default_handler(\&blah);
print " [OK]\n";
add_time("starting...\n");
$irc->start;
