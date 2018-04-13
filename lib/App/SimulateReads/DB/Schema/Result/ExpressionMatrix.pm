use utf8;
package App::SimulateReads::DB::Schema::Result::ExpressionMatrix;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

App::SimulateReads::DB::Schema::Result::ExpressionMatrix

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<expression_matrix>

=cut

__PACKAGE__->table("expression_matrix");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: (empty string)
  is_nullable: 0

=head2 source

  data_type: 'text'
  default_value: 'not defined'
  is_nullable: 1

=head2 is_user_provided

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 matrix

  data_type: 'blob'
  is_nullable: 0

=head2 date

  data_type: 'date'
  default_value: CURRENT_DATE
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "", is_nullable => 0 },
  "source",
  { data_type => "text", default_value => "not defined", is_nullable => 1 },
  "is_user_provided",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "matrix",
  { data_type => "blob", is_nullable => 0 },
  "date",
  { data_type => "date", default_value => \"CURRENT_DATE", is_nullable => 1 },
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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-04-13 19:51:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gRsjxnWmHajWbBYRAn5LUQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
