package Cute::Class;
use strict;
use warnings;
use parent qw(
    Class::Accessor::Lvalue::Fast
    Class::Data::Inheritable
);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    my $init = $self->can('init') || $self->can('initialize');
       $init->($self) if $init;

    $self;
}

sub param {
    my $self = shift;
    if (@_ == 1) {
        my $key = shift;
        return $self->{$key};
    }
    elsif (@_ && @_ % 2 == 0) {
        my %args = @_;
        while (my ($key, $value) = each %args) {
            $self->{$key} = $value;
        }
        return $self;
    }
    else {
        return keys %$self;
    }
}

sub to_hash {
    my $self = shift;
    +{ map { $_ => $self->{$_} } $self->param };
}

!!1;
