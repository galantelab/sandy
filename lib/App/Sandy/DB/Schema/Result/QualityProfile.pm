use utf8;
package App::Sandy::DB::Schema::Result::QualityProfile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE


use strict;
use warnings;

use base 'DBIx::Class::Core';


__PACKAGE__->table("quality_profile");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "source",
  { data_type => "text", default_value => "not defined", is_nullable => 1 },
  "is_user_provided",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "is_single_molecule",
  { data_type => "integer", is_nullable => 0 },
  "mean",
  { data_type => "integer", is_nullable => 0 },
  "stdd",
  { data_type => "integer", is_nullable => 0 },
  "error",
  { data_type => "real", is_nullable => 0 },
  "deepth",
  { data_type => "integer", is_nullable => 0 },
  "partil",
  { data_type => "integer", is_nullable => 0 },
  "matrix",
  { data_type => "blob", is_nullable => 0 },
  "date",
  { data_type => "date", default_value => \"CURRENT_DATE", is_nullable => 1 },
);


__PACKAGE__->set_primary_key("id");


__PACKAGE__->add_unique_constraint("name_unique", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-07-31 20:22:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5r74uIOy2yUdN9U2wz3kmg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::DB::Schema::Result::QualityProfile

=head1 VERSION

version 0.25

=head1 NAME

App::Sandy::DB::Schema::Result::QualityProfile

=head1 TABLE: C<quality_profile>

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 source

  data_type: 'text'
  default_value: 'not defined'
  is_nullable: 1

=head2 is_user_provided

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 is_single_molecule

  data_type: 'integer'
  is_nullable: 0

=head2 mean

  data_type: 'integer'
  is_nullable: 0

=head2 stdd

  data_type: 'integer'
  is_nullable: 0

=head2 error

  data_type: 'real'
  is_nullable: 0

=head2 deepth

  data_type: 'integer'
  is_nullable: 0

=head2 partil

  data_type: 'integer'
  is_nullable: 0

=head2 matrix

  data_type: 'blob'
  is_nullable: 0

=head2 date

  data_type: 'date'
  default_value: CURRENT_DATE
  is_nullable: 1

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=head1 UNIQUE CONSTRAINTS

=head2 C<name_unique>

=over 4

=item * L</name>

=back

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Felipe R. C. dos Santos <fsantos@mochsl.org.br>

=item *

Helena B. Conceição <hconceicao@mochsl.org.br>

=item *

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Rafael Mercuri <rmercuri@mochsl.org.br>

=item *

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2023 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
