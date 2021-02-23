package Module::Features;

# AUTHORITY
# DATE
# DIST
# VERSION

1;
# ABSTRACT: Define features for modules

=head1 DESCRIPTION

This document specifies a very easy and lightweight way to define and declare
features for modules. A definer module defines some features in a feature set,
other modules declare these features that they have or don't have, and user can
easily check and select modules based on features he/she wants.


=head1 SPECIFICATION STATUS

The series 0.1.x version is still unstable.


=head1 SPECIFICATION VERSION

0.1


=head1 GLOSSARY

=head2 feature definer module

A module in "C<Module::Features::>I<FeatureSetName>" namespace that contains
L</"feature set specification">. This module describes what each feature in the
feature set means, what values are valid for the feature, and so on. A
L</"feature declarer module"> follows this specification and declares features.

=head2 feature declarer module

A regular Perl module that wants to declare some features defined by L</"feature
definer module">. Module name must not end with C<::_ModuleFeatures>, in which
case it is a L</"feature declarer proxy module">.

=head2 feature declarer proxy module

A module that declares features for another module. Module name must end with
C<::_ModuleFeatures> and the name of the module it delares features for is its
own name sans the C<::_ModuleFeatures> suffix. For example, the module
L<Text::Table::Tiny::_ModuleFeatures> contains L</"features declaration"> for
L<Text::Table::Tiny>.

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

=head2 features declaration

A L<DefHash> containing a list of feature set names and feature values for
features of those feature sets.


=head1 SPECIFICATION

=head2 Defining feature set

A L</"feature definer module"> specifies feature set by putting the L</"feature
set specification"> in C<%FEATURES_DEF> package variable. Specifying feature set
should not require any module dependency.

For example, in L<Module::Features::TextTable>:

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

A L</"feature declarer module"> declares features that it supports (or does not
support) via putting the L</"features declaration"> in C<%FEATURES> package
variable. Declaring features should not require any module dependency, but a
helper module can be written to help check that declared feature sets and
features are known and the feature values conform to defined schemas.

Not all features from a feature set need to be declared by the feature declarer
module. The undeclared features will have C<undef> as their values for the
declarer module. However, features defined as required (C<< req => 1 >> in the
specification) MUST be declared.

For example, in L<Text::Table::More>:

 # a DefHash
 our %FEATURES = (
     # optional, specifies which module version this declaration pertains to
     #module_v => "0.002",

     # optional, a numeric value to be compared against other declarations for
     # the same module. recommended form is YYYYMMDD. for multiple serials in a
     # single day, you can use YYYYMMDD.1, YYYYMMDD.2, YYYYMMDD.91, and so on.
     #serial => 20210223,

     features => {
         # each key is a feature set name.
         TextTable => {
             # each key is a feature name defined in the feature set. each value
             # is either a feature value, or a DefHash that contains the feature
             # value in the 'value' property, and notes in 'summary', and other
             # things.
             align_cell_containing_color_codes     => 1,
             align_cell_containing_wide_characters => 1,
             align_cell_containing_multiple_lines  => 1,
             speed => {
                 value => 'slow', # if unspecified, value will become undef
                 summary => "It's certainly slower than Text::Table::Tiny, etc; and it can still be made faster after some optimization",
             },
         },
     },
 );

While in L<Text::Table::Sprintf>:

 our %FEATURES = (
     features => {
         TextTable => {
             align_cell_containing_color_codes     => 0,
             align_cell_containing_wide_characters => 0,
             align_cell_containing_multiple_lines  => 0,
             speed                                 => 'fast',
         },
     },
 );

and in L<Text::Table::Any>:

 our %FEATURES = (
     features => {
         TextTable => {
             align_cell_containing_color_codes     => {value => undef, summary => 'Depends on the backend used'},
             align_cell_containing_wide_characters => {value => undef, summary => 'Depends on the backend used'},
             align_cell_containing_multiple_lines  => {value => undef, summary => 'Depends on the backend used'},
             speed                                 => {value => undef, summary => 'Depends on the backend used'},
         },
     },
 );

Features declaration can also be put in other places:

=over

=item * %FEATURES package variable in the L</"feature declarer proxy module">

=item * database

=item * others

=back

The %FEATURES package variable in the feature declarer module itself is
considered to be authoritative, but other places can be checked first to avoid
having to load the feature declarer module. When multiple features declaration
exist, the C<module_v> and/or C<serial> can be used to find out which
declaration is the most recent or suitable.


=head2 Checking whether a module has a certain feature

The user of a L</"feature declarer module"> can check whether the module has a
certain feature simply by checking the module's L</"features declaration">
(C<%FEATURES>). Checking features of a module should not require any module
dependency.

For example, to check whether Text::Table::Sprintf supports aligning cells that
contain multiple lines:

 if (do { my $val = $Text::Table::Sprintf::FEATURES{features}{TextTable}{align_cell_containing_multiple_lines}; ref $val eq 'HASH' ? $val->{value} : $val }) {
     ...
 }

A utility module can be written to help make this more convenient.


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
