# NAME

DBIx::Class::EncodedColumn - Automatically encode columns

# SYNOPSIS

In your [DBIx::Class](https://metacpan.org/pod/DBIx%3A%3AClass) Result class
(sometimes erroneously referred to as the 'table' class):

    __PACKAGE__->load_components(qw/EncodedColumn ... Core/);

    #Digest encoder with hex format and SHA-1 algorithm
    __PACKAGE__->add_columns(
      'password' => {
        data_type     => 'CHAR',
        size          => 40,
        encode_column => 1,
        encode_class  => 'Digest',
        encode_args   => {algorithm => 'SHA-1', format => 'hex'},
    }

    #SHA-1 / hex encoding / generate check method
    __PACKAGE__->add_columns(
      'password' => {
        data_type   => 'CHAR',
        size        => 40 + 10,
        encode_column => 1,
        encode_class  => 'Digest',
        encode_args   => {algorithm => 'SHA-1', format => 'hex', salt_length => 10},
        encode_check_method => 'check_password',
    }

    #MD5 /  base64 encoding / generate check method
    __PACKAGE__->add_columns(
      'password' => {
        data_type => 'CHAR',
        size      => 22,
        encode_column => 1,
        encode_class  => 'Digest',
        encode_args   => {algorithm => 'MD5', format => 'base64'},
        encode_check_method => 'check_password',
    }

    #Eksblowfish bcrypt / cost of 8/ no key_nul / generate check method
    __PACKAGE__->add_columns(
      'password' => {
        data_type => 'CHAR',
        size      => 59,
        encode_column => 1,
        encode_class  => 'Crypt::Eksblowfish::Bcrypt',
        encode_args   => { key_nul => 0, cost => 8 },
        encode_check_method => 'check_password',
    }

In your application code:

    #updating the value.
    $row->password('plaintext');
    my $digest = $row->password;

    #checking against an existing value with a check_method
    $row->check_password('old_password'); #true
    $row->password('new_password');
    $row->check_password('new_password'); #returns true
    $row->check_password('old_password'); #returns false

**Note:** The component needs to be loaded _before_ Core and other components
such as Timestamp. Core should always be last.

    E.g:
    __PACKAGE__->load_components(qw/EncodedColumn TimeStamp Core/);

# DESCRIPTION

This [DBIx::Class](https://metacpan.org/pod/DBIx%3A%3AClass) component can be used to automatically encode a column's
contents whenever the value of that column is set.

This module is similar to the existing [DBIx::Class::DigestColumns](https://metacpan.org/pod/DBIx%3A%3AClass%3A%3ADigestColumns), but there
is some key differences:

- `DigestColumns` performs the encode operation on `insert` and `update`,
and `EncodedColumn` performs the operation when the value is set, or on `new`.
- `DigestColumns` supports only algorithms of the [Digest](https://metacpan.org/pod/Digest) family.
`EncodedColumn` employs a set of thin wrappers around different cipher modules
to provide support for any cipher you wish to use and wrappers are very simple
to write (typically less than 30 lines).
- `EncodedColumn` supports having more than one encoded column per table
and each column can use a different cipher.
- `Encode` adds only one item to the namespace of the object utilizing
it (`_column_encoders`).

There is, unfortunately, some features that `EncodedColumn` doesn't support.
`DigestColumns` supports changing certain options at runtime, as well as
the option to not automatically encode values on set. The author of this module
found these options to be non-essential and omitted them by design.

# Options added to add\_column

## encode\_column => 1

Enable automatic encoding of column values. If this option is not set to true
any other options will become no-ops.

## encode\_check\_method => $method\_name

By using the encode\_check\_method attribute when you declare a column you
can create a check method for that column. The check method accepts a plain
text string, and returns a boolean that indicates whether the digest of the
provided value matches the current value.

## encode\_class

The class to use for encoding. Available classes are:

- `Crypt::Eksblowfish::Bcrypt` - uses
[DBIx::Class::EncodedColumn::Crypt::Eksblowfish::Bcrypt](https://metacpan.org/pod/DBIx%3A%3AClass%3A%3AEncodedColumn%3A%3ACrypt%3A%3AEksblowfish%3A%3ABcrypt) and
requires [Crypt::Eksblowfish::Bcrypt](https://metacpan.org/pod/Crypt%3A%3AEksblowfish%3A%3ABcrypt) to be installed
- `Digest` - uses [DBIx::Class::EncodedColumn::Digest](https://metacpan.org/pod/DBIx%3A%3AClass%3A%3AEncodedColumn%3A%3ADigest)
requires [Digest](https://metacpan.org/pod/Digest) to be installed as well as the algorithm required
([Digest::SHA](https://metacpan.org/pod/Digest%3A%3ASHA), [Digest::Whirlpool](https://metacpan.org/pod/Digest%3A%3AWhirlpool), etc)
- `Crypt::OpenPGP` - [DBIx::Class::EncodedColumn::Crypt::OpenPGP](https://metacpan.org/pod/DBIx%3A%3AClass%3A%3AEncodedColumn%3A%3ACrypt%3A%3AOpenPGP)
and requires [Crypt::OpenPGP](https://metacpan.org/pod/Crypt%3A%3AOpenPGP) to be installed

Please see the relevant class's documentation for information about the
specific arguments accepted by each and make sure you include the encoding
algorithm (e.g. [Crypt::OpenPGP](https://metacpan.org/pod/Crypt%3A%3AOpenPGP)) in your application's requirements.

# EXTENDED METHODS

The following [DBIx::Class::ResultSource](https://metacpan.org/pod/DBIx%3A%3AClass%3A%3AResultSource) method is extended:

- **register\_column** - Handle the options described above.

The following [DBIx::Class::Row](https://metacpan.org/pod/DBIx%3A%3AClass%3A%3ARow) methods are extended by this module:

- **new** - Encode the columns on new() so that copy and create DWIM.
- **set\_column** - Encode values whenever column is set.

# SEE ALSO

[DBIx::Class::DigestColumns](https://metacpan.org/pod/DBIx%3A%3AClass%3A%3ADigestColumns), [DBIx::Class](https://metacpan.org/pod/DBIx%3A%3AClass), [Digest](https://metacpan.org/pod/Digest)

# AUTHOR

Guillermo Roditi (groditi) <groditi@cpan.org>

Inspired by the original module written by Tom Kirkpatrick (tkp) <tkp@cpan.org>
featuring contributions from Guillermo Roditi (groditi) <groditi@cpan.org>
and Marc Mims <marc@questright.com>

# CONTRIBUTORS

jshirley - J. Shirley <cpan@coldhardcode.com>

kentnl - Kent Fredric <kentnl@cpan.org>

mst - Matt S Trout <mst@shadowcat.co.uk>

wreis - Wallace Reis <wreis@cpan.org>

# COPYRIGHT

Copyright (c) the DBIx::Class::EncodedColumn ["AUTHOR"](#author) and ["CONTRIBUTORS"](#contributors) as
listed above.

# LICENSE

This library is free software and may be distributed under the same terms
as perl itself.
