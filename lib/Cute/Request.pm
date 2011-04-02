package Cute::Request;
use strict;
use warnings;
use parent qw(Plack::Request);

use Plack::Util::Accessor qw(_path_query);

use Cute::Class;

sub path_query {
    my $self = shift;
       $self->_path_query(Cute::Class->new) if !$self->_path_query;

    if (@_) {
        return $self->_path_query->param(@_);
    }

    $self->_path_query;
}

!!1;
