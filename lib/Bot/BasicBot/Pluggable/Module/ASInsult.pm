package Bot::BasicBot::Pluggable::Module::ASInsult;

use strict;
use Bot::BasicBot::Pluggable::Module; 
use Acme::Scurvy::Whoreson::BilgeRat;
use base qw(Bot::BasicBot::Pluggable::Module);

sub said { 
    my ($self, $mess, $pri) = @_;

    my $body = $mess->{body}; 
    my $who  = $mess->{who};

    return unless ($pri == 2);
    return unless $body =~ /^\s*insult (.*)\s*$/;

    my $person   = $1;
    
    $person = $who if $person =~ /^\s*me\s*$/i;

    my $insultgenerator = Acme::Scurvy::Whoreson::BilgeRat->new( language => 'insultserver' ); # try: pirate, lala, insultserver

    my $insult = "$insultgenerator";    


    return "Errk, the insult code is mysteriously not working" unless defined $insult;

#    $insult =~ s/^\s*You are/$person is/i if ($person ne $who);  
    $insult = $person.": ".$insult;

    return $insult;
}

sub help {
    return "Commands: 'insult <who>'";
}

1;


__END__

=head1 NAME

Bot::BasicBot::Pluggable::Module::Insult - insult people (in a variety of languages)

=head1 SYNOPSIS


=head1 IRC USAGE

    insult <who> [in <language>]

=head1 AUTHOR

Simon Wistow, <simon@thegestalt.org>

=head1 COPYRIGHT

Copyright 2005, Simon Wistow

Distributed under the same terms as Perl itself.

=head1 SEE ALSO

L<Math::Units>

=cut 

