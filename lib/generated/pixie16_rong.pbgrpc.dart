//
//  Generated code. Do not modify.
//  source: pixie16_rong.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'pixie16_rong.pb.dart' as $0;

export 'pixie16_rong.pb.dart';

@$pb.GrpcServiceName('rong.pixie16')
class pixie16Client extends $grpc.Client {
  static final _$getState = $grpc.ClientMethod<$0.Request, $0.Reply>(
      '/rong.pixie16/GetState',
      ($0.Request value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Reply.fromBuffer(value));
  static final _$runControl = $grpc.ClientMethod<$0.Action, $0.Reply>(
      '/rong.pixie16/RunControl',
      ($0.Action value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Reply.fromBuffer(value));

  pixie16Client($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.Reply> getState($0.Request request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getState, request, options: options);
  }

  $grpc.ResponseFuture<$0.Reply> runControl($0.Action request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$runControl, request, options: options);
  }
}

@$pb.GrpcServiceName('rong.pixie16')
abstract class pixie16ServiceBase extends $grpc.Service {
  $core.String get $name => 'rong.pixie16';

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

  $async.Future<$0.Reply> getState_Pre($grpc.ServiceCall call, $async.Future<$0.Request> request) async {
    return getState(call, await request);
  }

  $async.Future<$0.Reply> runControl_Pre($grpc.ServiceCall call, $async.Future<$0.Action> request) async {
    return runControl(call, await request);
  }

  $async.Future<$0.Reply> getState($grpc.ServiceCall call, $0.Request request);
  $async.Future<$0.Reply> runControl($grpc.ServiceCall call, $0.Action request);
}
