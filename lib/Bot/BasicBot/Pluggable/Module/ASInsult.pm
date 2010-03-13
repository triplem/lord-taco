package Bot::BasicBot::Pluggable::Module::ASInsult;

use strict;
use Bot::BasicBot::Pluggable::Module; 
use Acme::Scurvy::Whoreson::BilgeRat;
use base qw(Bot::BasicBot::Pluggable::Module);

sub seen { 
    my ($self, $mess) = @_;

    my $body = $mess->{body}; 

    return 0 unless defined $body;
    
    my $who  = $mess->{who};

    return 0 unless $body =~ /^insult (.*)\s*$/;

    my $person = $1;
    
    $person = $who if $person =~ /^\s*me\s*$/i;

    my $insultgenerator = Acme::Scurvy::Whoreson::BilgeRat->new( language => 'insultserver' ); # try: pirate, lala, insultserver

    my $insult = "$insultgenerator";    

    $self->reply($mess, "Errk, the insult code is mysteriously not working") unless defined $insult;

#    $insult =~ s/^\s*You are/$person is/i if ($person ne $who);  
    $insult = $person.": ".$insult;

    $self->reply($mess, $insult);
}

sub help {
    return "Commands: 'insult <who>'";
}

1;


__END__

=head1 NAME

Bot::BasicBot::Pluggable::Module::ASInsult - insult people

=head1 SYNOPSIS


=head1 IRC USAGE

    insult <who>

=head1 AUTHOR

Markus M. May, <triplem@tu.archserver.org>

Based on the work of Simon Wistow (Bot::BasicBot::Pluggable::Module::Insult).

=head1 COPYRIGHT

Copyright 2005, Simon Wistow
Copyright 2010, Markus M. May

Distributed under the same terms as Perl itself.

=head1 SEE ALSO

L<Math::Units>
L<Bot::BasicBot::Pluggable::Module::Insult>

=cut 

