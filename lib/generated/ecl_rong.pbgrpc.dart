//
//  Generated code. Do not modify.
//  source: ecl_rong.proto
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

import 'ecl_rong.pb.dart' as $0;

export 'ecl_rong.pb.dart';

@$pb.GrpcServiceName('rong.ecl')
class eclClient extends $grpc.Client {
  static final _$getState = $grpc.ClientMethod<$0.Request, $0.Reply>(
      '/rong.ecl/GetState',
      ($0.Request value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Reply.fromBuffer(value));
  static final _$getScaler = $grpc.ClientMethod<$0.Request, $0.Reply>(
      '/rong.ecl/GetScaler',
      ($0.Request value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Reply.fromBuffer(value));
  static final _$getScalerRecent = $grpc.ClientMethod<$0.RecentRequest, $0.Reply>(
      '/rong.ecl/GetScalerRecent',
      ($0.RecentRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Reply.fromBuffer(value));
  static final _$getScalerDate = $grpc.ClientMethod<$0.DateRequest, $0.Reply>(
      '/rong.ecl/GetScalerDate',
      ($0.DateRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Reply.fromBuffer(value));
  static final _$getConfig = $grpc.ClientMethod<$0.Request, $0.Expression>(
      '/rong.ecl/GetConfig',
      ($0.Request value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Expression.fromBuffer(value));
  static final _$setConfig = $grpc.ClientMethod<$0.Expression, $0.ParseResponse>(
      '/rong.ecl/SetConfig',
      ($0.Expression value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ParseResponse.fromBuffer(value));
  static final _$runControl = $grpc.ClientMethod<$0.Action, $0.Reply>(
      '/rong.ecl/RunControl',
      ($0.Action value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Reply.fromBuffer(value));

  eclClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.Reply> getState($0.Request request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getState, request, options: options);
  }

  $grpc.ResponseStream<$0.Reply> getScaler($0.Request request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$getScaler, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseStream<$0.Reply> getScalerRecent($0.RecentRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$getScalerRecent, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseStream<$0.Reply> getScalerDate($0.DateRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$getScalerDate, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseStream<$0.Expression> getConfig($0.Request request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$getConfig, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$0.ParseResponse> setConfig($async.Stream<$0.Expression> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$setConfig, request, options: options).single;
  }

  $grpc.ResponseFuture<$0.Reply> runControl($0.Action request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$runControl, request, options: options);
  }
}

@$pb.GrpcServiceName('rong.ecl')
abstract class eclServiceBase extends $grpc.Service {
  $core.String get $name => 'rong.ecl';

  eclServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Request, $0.Reply>(
        'GetState',
        getState_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Request.fromBuffer(value),
        ($0.Reply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Request, $0.Reply>(
        'GetScaler',
        getScaler_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Request.fromBuffer(value),
        ($0.Reply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RecentRequest, $0.Reply>(
        'GetScalerRecent',
        getScalerRecent_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.RecentRequest.fromBuffer(value),
        ($0.Reply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DateRequest, $0.Reply>(
        'GetScalerDate',
        getScalerDate_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.DateRequest.fromBuffer(value),
        ($0.Reply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Request, $0.Expression>(
        'GetConfig',
        getConfig_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Request.fromBuffer(value),
        ($0.Expression value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Expression, $0.ParseResponse>(
        'SetConfig',
        setConfig,
        true,
        false,
        ($core.List<$core.int> value) => $0.Expression.fromBuffer(value),
        ($0.ParseResponse value) => value.writeToBuffer()));
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

  $async.Stream<$0.Reply> getScaler_Pre($grpc.ServiceCall call, $async.Future<$0.Request> request) async* {
    yield* getScaler(call, await request);
  }

  $async.Stream<$0.Reply> getScalerRecent_Pre($grpc.ServiceCall call, $async.Future<$0.RecentRequest> request) async* {
    yield* getScalerRecent(call, await request);
  }

  $async.Stream<$0.Reply> getScalerDate_Pre($grpc.ServiceCall call, $async.Future<$0.DateRequest> request) async* {
    yield* getScalerDate(call, await request);
  }

  $async.Stream<$0.Expression> getConfig_Pre($grpc.ServiceCall call, $async.Future<$0.Request> request) async* {
    yield* getConfig(call, await request);
  }

  $async.Future<$0.Reply> runControl_Pre($grpc.ServiceCall call, $async.Future<$0.Action> request) async {
    return runControl(call, await request);
  }

  $async.Future<$0.Reply> getState($grpc.ServiceCall call, $0.Request request);
  $async.Stream<$0.Reply> getScaler($grpc.ServiceCall call, $0.Request request);
  $async.Stream<$0.Reply> getScalerRecent($grpc.ServiceCall call, $0.RecentRequest request);
  $async.Stream<$0.Reply> getScalerDate($grpc.ServiceCall call, $0.DateRequest request);
  $async.Stream<$0.Expression> getConfig($grpc.ServiceCall call, $0.Request request);
  $async.Future<$0.ParseResponse> setConfig($grpc.ServiceCall call, $async.Stream<$0.Expression> request);
  $async.Future<$0.Reply> runControl($grpc.ServiceCall call, $0.Action request);
}
