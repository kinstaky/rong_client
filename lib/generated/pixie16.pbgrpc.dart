// This is a generated file - do not edit.
//
// Generated from pixie16.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'pixie16.pb.dart' as $0;

export 'pixie16.pb.dart';

@$pb.GrpcServiceName('easydaq.pixie16')
class pixie16Client extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  pixie16Client(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Reply> getState(
    $0.Request request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getState, request, options: options);
  }

  $grpc.ResponseFuture<$0.Reply> runControl(
    $0.Action request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$runControl, request, options: options);
  }

  // method descriptors

  static final _$getState = $grpc.ClientMethod<$0.Request, $0.Reply>(
      '/easydaq.pixie16/GetState',
      ($0.Request value) => value.writeToBuffer(),
      $0.Reply.fromBuffer);
  static final _$runControl = $grpc.ClientMethod<$0.Action, $0.Reply>(
      '/easydaq.pixie16/RunControl',
      ($0.Action value) => value.writeToBuffer(),
      $0.Reply.fromBuffer);
}

@$pb.GrpcServiceName('easydaq.pixie16')
abstract class pixie16ServiceBase extends $grpc.Service {
  $core.String get $name => 'easydaq.pixie16';

  pixie16ServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Request, $0.Reply>(
        'GetState',
        getState_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Request.fromBuffer(value),
        ($0.Reply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Action, $0.Reply>(
        'RunControl',
        runControl_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Action.fromBuffer(value),
        ($0.Reply value) => value.writeToBuffer()));
  }

  $async.Future<$0.Reply> getState_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Request> $request) async {
    return getState($call, await $request);
  }

  $async.Future<$0.Reply> getState($grpc.ServiceCall call, $0.Request request);

  $async.Future<$0.Reply> runControl_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Action> $request) async {
    return runControl($call, await $request);
  }

  $async.Future<$0.Reply> runControl($grpc.ServiceCall call, $0.Action request);
}
