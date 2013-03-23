#! /usr/bin/perl -w

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;
use Module::Install::ReadmeFromPod;

# Define metadata
name 'DBIx-Class-EncodedColumn';
abstract "Automatically encode column values";
all_from 'lib/DBIx/Class/EncodedColumn.pm';
readme_from;
repository 'git://github.com/wreis/DBIx-Class-EncodedColumn.git';

# Specific dependencies
requires 'DBIx::Class' => '0.06002';
requires 'Sub::Name' => '0.04';
requires 'Encode';

#build dependencies
test_requires 'Test::More';
test_requires 'DBD::SQLite';
test_requires 'Dir::Self';
test_requires 'File::Temp';
test_requires 'File::Spec';

auto_install;

WriteAll;
