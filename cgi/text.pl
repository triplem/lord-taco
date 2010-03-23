#!/usr/bin/perl
use lib '/srv/ilbot/lib';
use warnings;
use strict;
use Carp qw(confess);
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use Encode;
use HTML::Entities;
# evil hack: Text::Table lies somewhere near /irclog/ on the server...
use lib '../lib';
use lib 'lib';
use IrcLog qw(get_dbh gmt_today);
use IrcLog::WWW qw(my_encode my_decode);
use Text::Table;
use Bot::BasicBot::Pluggable::Module::DBAccess;

my $default_channel = 'ArchServer';

# End of config

my $q = new CGI;
my $dbh = Bot::BasicBot::Pluggable::Module::DBAccess->get_dbh("/srv/ilbot/database.conf");
my $channel = $q->param('channel') || $default_channel;

my $date = $q->param('date') || gmt_today;

if ($channel !~ m/^\w+(?:-\w+)*\z/sx){
    # guard against channel=../../../etc/passwd or so
    confess 'Invalid channel name';
}
my $db = $dbh->prepare('SELECT nick, seen_date, line FROM irclog '
        . 'WHERE day = ? AND channel = ? AND NOT spam ORDER BY id');
$db->execute($date, '#' . $channel);


print "Content-Type: text/html;charset=utf-8\n\n";
print <<HTML_HEADER;
<html>
<head>
<title>IRC Logs</title>
</head>
<body>
<pre>
HTML_HEADER

my $table = Text::Table->new(qw(Time Nick Message));

while (my $row = $db->fetchrow_hashref){
    next unless length($row->{nick});
    my ($hour, $minute) =(gmtime $row->{timestamp})[2,1];  
    $table->add(
            sprintf("%02d:%02d", $hour, $minute),
            $row->{nick},
            my_decode($row->{line}),
            );
}
my $text = encode_entities($table, '<>&');

# Text::Table will add trailing whitespace to pad messages to the
# longest message. I (avar) wasn't able to find out how to make it
# stop doing that so I'm hacking around it with regex! 
$text =~ s/ +$//gm;

print encode("utf-8", $text);
print "</pre></body></html>\n";




# vim: sw=4 ts=4 expandtab
