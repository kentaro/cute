package Cute::Context;
use strict;
use warnings;
use parent qw(Cute::Class);
use Cute::Class;

__PACKAGE__->mk_accessors(qw(
    controller
    request
    response
    _stash
));

*req = \&request;
*res = \&response;

sub stash {
    my $self = shift;
       $self->_stash ||= Cute::Class->new;

    if (@_) {
        return $self->_stash->param(@_);
    }

    $self->_stash;
}

!!1;
