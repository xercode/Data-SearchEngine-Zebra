package Data::SearchEngine::Zebra::Item;

use Modern::Perl;
use Carp;
use ZOOM;
use XML::Simple;
use MARC::Record;

use Moose;

extends 'Data::SearchEngine::Item';

has record => ( is => 'rw', isa => 'Str');

sub BUILD{
    my $self=shift;
    my $_record = MARC::Record->new_from_usmarc($self->record);
    $self->id($_record->field('999')->subfield('c'));
}

1;

=pod

=encoding UTF-8

=head1 NAME

Data::SearchEngine::Zebra::Item - Zebra search engine abstraction.

=head1 VERSION

version 0.01

=head1 ATTRIBUTES

=head2 record

Record in marc format

=head1 METHODS

=head1 AUTHOR

Juan Romay Sieira <juan.sieira@xercode.es>
Henri-Damien Laurent <henridamien.laurent@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Xercode Media Software.
This software is Copyright (c) 2012 by Biblibre.

This is free software, licensed under:

    The GNU General Public License, Version 3, 29 June 2007

=cut