#! /usr/bin/perl -w

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name 'DBIx-Class-EncodedColumn';
abstract "Automatically encode column values";
all_from 'lib/DBIx/Class/EncodedColumn.pm';

repository 'http://dev.catalyst.perl.org/repos/bast/trunk/DBIx-Class-EncodedColumn';

# Specific dependencies
requires 'DBIx::Class' => '0.06002';
requires 'Sub::Name' => '0.04';

#build dependencies
test_requires 'Test::More';
test_requires 'DBD::SQLite';
test_requires 'Dir::Self';
test_requires 'File::Temp';
test_requires 'File::Spec';

auto_install;

WriteAll;
