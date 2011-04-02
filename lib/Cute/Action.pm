package Cute::Action;
use strict;
use warnings;
use parent qw(Cute::Class);

__PACKAGE__->mk_accessors(qw(
    actions
));

sub slot {
    my ($self, $path, $method, $code) = @_;
    $method = lc $method;
    $self->actions ||= {};
    $self->actions->{$path} ||= {};
    if (defined $code) {
        $self->actions->{$path}{$method} = $code;
    }
    $self->actions->{$path}{$method};
}

sub register {
    my ($self, $path, $method, $code) = @_;
    $self->slot($path, $method, $code)
}

sub unregister {
    my ($self, $path, $method) = @_;
    $self->slot($path, $method, '')
}

sub retrieve {
    my ($self, $path, $method) = @_;
    $self->slot($path, $method);
}

!!1;
