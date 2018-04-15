use utf8;
package App::SimulateReads::DB::Schema::Result::SequencingSystem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE


use strict;
use warnings;

use base 'DBIx::Class::Core';


__PACKAGE__->table("sequencing_system");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
);


__PACKAGE__->set_primary_key("id");


__PACKAGE__->add_unique_constraint("name_unique", ["name"]);


__PACKAGE__->has_many(
  "qualities",
  "App::SimulateReads::DB::Schema::Result::Quality",
  { "foreign.sequencing_system_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-03-30 20:36:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cng0D2lvZ+cuqwUD7e3Icw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::DB::Schema::Result::SequencingSystem

=head1 VERSION

version 0.15

=head1 NAME

App::SimulateReads::DB::Schema::Result::SequencingSystem

=head1 TABLE: C<sequencing_system>

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=head1 UNIQUE CONSTRAINTS

=head2 C<name_unique>

=over 4

=item * L</name>

=back

=head1 RELATIONS

=head2 qualities

Type: has_many

Related object: L<App::SimulateReads::DB::Schema::Result::Quality>

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
