use utf8;
package App::SimulateReads::DB::Schema::Result::Quality;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

App::SimulateReads::DB::Schema::Result::Quality

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<quality>

=cut

__PACKAGE__->table("quality");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sequencing_system_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 source

  data_type: 'text'
  default_value: 'not defined'
  is_nullable: 1

=head2 is_user_provided

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 size

  data_type: 'integer'
  is_nullable: 0

=head2 deepth

  data_type: 'integer'
  is_nullable: 0

=head2 matrix

  data_type: 'blob'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sequencing_system_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "source",
  { data_type => "text", default_value => "not defined", is_nullable => 1 },
  "is_user_provided",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "size",
  { data_type => "integer", is_nullable => 0 },
  "deepth",
  { data_type => "integer", is_nullable => 0 },
  "matrix",
  { data_type => "blob", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<sequencing_system_id_size_unique>

=over 4

=item * L</sequencing_system_id>

=item * L</size>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "sequencing_system_id_size_unique",
  ["sequencing_system_id", "size"],
);

=head1 RELATIONS

=head2 sequencing_system

Type: belongs_to

Related object: L<App::SimulateReads::DB::Schema::Result::SequencingSystem>

=cut

__PACKAGE__->belongs_to(
  "sequencing_system",
  "App::SimulateReads::DB::Schema::Result::SequencingSystem",
  { id => "sequencing_system_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-03-30 20:36:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9uv6FbTqlkXAN55xJER1fQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
