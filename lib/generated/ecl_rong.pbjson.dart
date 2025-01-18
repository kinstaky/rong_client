//
//  Generated code. Do not modify.
//  source: ecl_rong.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use requestDescriptor instead')
const Request$json = {
  '1': 'Request',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
  ],
};

/// Descriptor for `Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestDescriptor = $convert.base64Decode(
    'CgdSZXF1ZXN0EhIKBHR5cGUYASABKAVSBHR5cGU=');

@$core.Deprecated('Use replyDescriptor instead')
const Reply$json = {
  '1': 'Reply',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 5, '10': 'value'},
  ],
};

/// Descriptor for `Reply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List replyDescriptor = $convert.base64Decode(
    'CgVSZXBseRIUCgV2YWx1ZRgBIAEoBVIFdmFsdWU=');

@$core.Deprecated('Use recentRequestDescriptor instead')
const RecentRequest$json = {
  '1': 'RecentRequest',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'flag', '3': 2, '4': 1, '5': 13, '10': 'flag'},
  ],
};

/// Descriptor for `RecentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recentRequestDescriptor = $convert.base64Decode(
    'Cg1SZWNlbnRSZXF1ZXN0EhIKBHR5cGUYASABKAVSBHR5cGUSEgoEZmxhZxgCIAEoDVIEZmxhZw'
    '==');

@$core.Deprecated('Use dateRequestDescriptor instead')
const DateRequest$json = {
  '1': 'DateRequest',
  '2': [
    {'1': 'year', '3': 1, '4': 1, '5': 5, '10': 'year'},
    {'1': 'month', '3': 2, '4': 1, '5': 5, '10': 'month'},
    {'1': 'day', '3': 3, '4': 1, '5': 5, '10': 'day'},
    {'1': 'flag', '3': 4, '4': 1, '5': 13, '10': 'flag'},
  ],
};

/// Descriptor for `DateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dateRequestDescriptor = $convert.base64Decode(
    'CgtEYXRlUmVxdWVzdBISCgR5ZWFyGAEgASgFUgR5ZWFyEhQKBW1vbnRoGAIgASgFUgVtb250aB'
    'IQCgNkYXkYAyABKAVSA2RheRISCgRmbGFnGAQgASgNUgRmbGFn');

@$core.Deprecated('Use expressionDescriptor instead')
const Expression$json = {
  '1': 'Expression',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `Expression`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List expressionDescriptor = $convert.base64Decode(
    'CgpFeHByZXNzaW9uEhQKBXZhbHVlGAEgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use parseResponseDescriptor instead')
const ParseResponse$json = {
  '1': 'ParseResponse',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 5, '10': 'value'},
    {'1': 'index', '3': 2, '4': 1, '5': 5, '10': 'index'},
    {'1': 'position', '3': 3, '4': 1, '5': 5, '10': 'position'},
    {'1': 'length', '3': 4, '4': 1, '5': 5, '10': 'length'},
  ],
};

/// Descriptor for `ParseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List parseResponseDescriptor = $convert.base64Decode(
    'Cg1QYXJzZVJlc3BvbnNlEhQKBXZhbHVlGAEgASgFUgV2YWx1ZRIUCgVpbmRleBgCIAEoBVIFaW'
    '5kZXgSGgoIcG9zaXRpb24YAyABKAVSCHBvc2l0aW9uEhYKBmxlbmd0aBgEIAEoBVIGbGVuZ3Ro');

@$core.Deprecated('Use actionDescriptor instead')
const Action$json = {
  '1': 'Action',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'option', '3': 2, '4': 1, '5': 5, '10': 'option'},
    {'1': 'extra', '3': 3, '4': 1, '5': 5, '10': 'extra'},
  ],
};

/// Descriptor for `Action`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionDescriptor = $convert.base64Decode(
    'CgZBY3Rpb24SEgoEdHlwZRgBIAEoBVIEdHlwZRIWCgZvcHRpb24YAiABKAVSBm9wdGlvbhIUCg'
    'VleHRyYRgDIAEoBVIFZXh0cmE=');

