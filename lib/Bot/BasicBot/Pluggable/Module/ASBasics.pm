package Bot::BasicBot::Pluggable::Module::ASBasics;

use strict;
use Bot::BasicBot::Pluggable::Module;
use base qw(Bot::BasicBot::Pluggable::Module);

sub help {
  return "Commands: #bugs, #wiki";
};

sub init {
  my $self = shift;
  $self->config(
    { 
      user_wiki_url => "http://wiki.archserver.org/search/%s",
      user_bugs_search_url => "http://bugs.archserver.org/search/%s",
      user_bugs_url => "http://bugs.archserver.org/task/%s",
      user_bbs_url => "http://bbs.archserver.org/viewtopic.php?pid=%s", 
    }
  );
}

## This method is called for every seen message
sub seen { 
  my ( $self, $message ) = @_;

  my $body = $message->{body};
  return 0 unless defined $body;

  my $channel = $message->{channel};
  
  my ( $command, $param ) = split (/\s+/, $body, 2);
  $command = lc($command);  

  #### if there are keywords, attach them
  my $concat;
  if ($param) {
    my @wordArray = split( ' ', $param );
    foreach my $word (@wordArray) {
      if ($concat) {
        $concat = $concat . "+" . $word;
      } else {
        $concat = $word;
      }
    }
  }  
  
  my $return = "";
  if ( $command eq '#wiki' ) {
    $return = $self->get("user_wiki_url");
  } elsif ( $command eq '#bugs' ) {
    $return = $self->get("user_bugs_url");
  } elsif ( $command eq '#bugsearch' ) {
    $return = $self->get("user_bugs_search_url");     
  } elsif ( $command eq '#bbspost' ) {
    $return = $self->get("user_bbs_url");
  }
  
  $self->reply($message, sprintf( $return, $concat ));
}

1;

__END__

=head1 NAME


=head1 SYNOPSIS


=head1 IRC USAGE


=head1 AUTHOR

Markus M. May, <triplem@tu.archserver.org>

=head1 COPYRIGHT

Copyright 2010, Markus M. May

Distributed under the same terms as Perl itself.

=head1 SEE ALSO


=cut 

# vim: set ts=2 sw=2 et:
