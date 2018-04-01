use utf8;
package App::SimulateReads::DB::Schema::Result::SequencingSystem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

App::SimulateReads::DB::Schema::Result::SequencingSystem

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sequencing_system>

=cut

__PACKAGE__->table("sequencing_system");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_unique>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_unique", ["name"]);

=head1 RELATIONS

=head2 qualities

Type: has_many

Related object: L<App::SimulateReads::DB::Schema::Result::Quality>

=cut

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
