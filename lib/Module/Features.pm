package Module::Features;

# AUTHORITY
# DATE
# DIST
# VERSION

1;
# ABSTRACT: Define features for modules

=head1 DESCRIPTION

This document specifies a way to define and declare features for modules.


=head1 SPECIFICATION STATUS

The series 0.1.x version is still unstable.


=head1 SPECIFICATION VERSION

0.1


=head1 GLOSSARY

=head2 definer module

Module in the namespace of C<Module::Features::>I<FeatureSetName> that contains
L</"feature set specification">. This module defines what each feature in the
feature set means. A L</"user module"> follows the specification and declares
features.

=head2 user module

A regular Perl module that wants to define some features defined by L</"definer
module">.

=head2 feature name

A string, preferably an identifier matching regex pattern /\A\w+\z/.

=head2 feature value

The value of a feature.

=head2 feature specification

A L<DefHash>, containing the feature's summary, description, schema for value,
and other things.

=head2 feature set name

A string following regular Perl namespace name, e.g. C<JSON::Encoder> or
C<TextTable>.

=head2 feature set specification

A collection of L</"feature name">s along with each feature's
L<specification|/"feature specification">.


=head1 SPECIFICATION

=head2 Defining feature set

L<Definer module|/"definer module"> defines feature set by putting it in
C<%FEATURES_DEF> package variable. Defining feature set does not require any
module dependency.

For example, in C<Module::Features::TextTable>:

 # a DefHash
 our %FEATURES_DEF = (
     summary => 'Features of a text table generator',
     description => <<'_',
 This feature set defines features of a text table generator. By declaring these
 features, the module author makes it easier for module users to choose an
 appropriate module.
 _
     features => {
         # each key is a feature name. each value is the feature's specification.

         align_cell_containing_color_codes => {
             # a regular DefHash with common properties like 'summary',
             # 'description', 'tags', etc. can also contain these properties:
             # 'schema', 'req' (whether the feature must be declared by user
             # module).

             summary => 'Whether the module can align cells that contain ANSI color codes',
             # schema => 'bool*', # Sah schema. if not specified, the default is 'bool*'
         },
         align_cell_containing_multiple_lines => {
             summary => 'Whether the module can align cells that contain multiple lines of text',
         },
         align_cell_containing_wide_characters => {
             summary => 'Whether the module can align cells that contain wide Unicode characters',
         },
         speed => {
             summary => 'The speed of the module, according to the author',
             schema => ['int', in=>['slow', 'medium', 'fast']],
         },
     },
 );

=head2 Declaring features

L<User module|/"user module"> declares features that it supports (or does not
support) via putting it in C<%FEATURES> package variable. Declaring features
does not require any module dependency, but a helper module can be written to
help check that declared feature sets and features are known and the feature
values conform to defined schemas.

For example, in L<Text::Table::More>:

 our %FEATURES = (
     # each key is a feature set name.
     TextTable => {
         # each key is a feature name defined in the feature set. each value is
         # either a feature value, or a DeHash that contains the feature value
         # in the 'feature' property, and notes in 'summary', and other things.
         align_cell_containing_color_codes     => 1,
         align_cell_containing_wide_characters => 1,
         align_cell_containing_multiple_lines  => 1,
         speed => {
             value => 'slow',
             summary => "It's certainly slower than Text::Table::Tiny, etc; and it can still be made faster after some optimization",
         },
     },
 );

While in L<Text::Table::Sprintf>:

 our %FEATURES = (
     TextTable => {
         align_cell_containing_color_codes     => 1,
         align_cell_containing_wide_characters => 1,
         align_cell_containing_multiple_lines  => 1,
         speed                                 => 'fast',
     },
 );

and in L<Text::Table::Any>:

 our %FEATURES = (
     TextTable => {
         align_cell_containing_color_codes     => {value => undef, summary => 'Depends on the backend used'},
         align_cell_containing_wide_characters => {value => undef, summary => 'Depends on the backend used'},
         align_cell_containing_multiple_lines  => {value => undef, summary => 'Depends on the backend used'},
         speed                                 => {value => undef, summary => 'Depends on the backend used'},
     },
 );

=head2 Checking whether a module has a certain feature

A L</"user module"> user can check whether a user module has a certain feature
simply by checking the user module's C<%FEATURES>. For example, to check whether
Text::Table::Sprintf supports aligning cells that contain multiple lines:

 if (do { my $val = $Text::Table::Sprintf::FEATURES{TextTable}{align_cell_containing_multiple_lines}; ref $val eq 'HASH' ? $val->{value} : $val }) {
     ...
 }

A utility module can be written to help make this more convenient.


=head2 Selecting modules by its feature

Each module that one wants to select can be loaded and its C<%FEATURES> read. To
avoid loading lots of modules, the features declaration can also be put
somewhere else if wanted, like database, or per-distribution shared files, or
distribution metadata. Currently no specific recommendation is given.


=head1 FAQ

=head2 Why not roles?

Role frameworks like L<Role::Tiny> allow you to require a module to have certain
subroutines, i.e. to follow some kind of interface. This can be used to achieve
the same goal of defining and declaring features, by representing features as
required subroutines and feature sets as roles. However, Module::Features wants
declaring features to have negligible overhead, including no extra runtime
dependency.


=head1 SEE ALSO

L<DefHash>

L<Sah>
