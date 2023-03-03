import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:brick_core/core.dart';

import 'package:brick_rest/brick_rest.dart';
import '__mocks__.dart';

RestProvider generateProvider(String response, {String? requestBody, String? requestMethod}) {
  return RestProvider(
    'http://0.0.0.0:3000',
    modelDictionary: restModelDictionary,
    client: generateClient(response, requestBody: requestBody, requestMethod: requestMethod),
  );
}

void main() {
  group('RestProvider', () {
    group('#get', () {
      test('simple', () async {
        final provider = generateProvider('[{"name": "Thomas"}]');

        final instance = await provider.get<DemoRestModel>();
        expect(instance.first.name, 'Thomas');
      });

      test('without specifying a top level key', () async {
        final provider = generateProvider('{"people": [{"name": "Thomas"}]}');
        final instance = await provider.get<DemoRestModel>();
        expect(instance.first.name, 'Thomas');
      });
    });

    test('#defaultHeaders', () async {
      final headers = {'Authorization': 'token=12345'};
      final provider = generateProvider('[{"name": "Guy"}]');

      provider.defaultHeaders = headers;
      final instance = await provider.get<DemoRestModel>();
      expect(instance.first.name, 'Guy');
    });

    group('#upsert', () {
      test('basic', () async {
        final provider = generateProvider('{"name": "Guy"}', requestMethod: 'POST');

        final instance = DemoRestModel('Guy');
        final resp = await provider.upsert<DemoRestModel>(instance);
        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Guy"}');
      });

      test('providerArgs["request"]["headers"]', () async {
        final provider = RestProvider(
          'http://0.0.0.0:3000',
          modelDictionary: restModelDictionary,
          client: MockClient((req) async {
            if (req.method == 'POST' && req.headers['Authorization'] == 'Basic xyz') {
              return http.Response('{"name": "Thomas"}', 200);
            }

            throw StateError('No response');
          }),
        );

        final instance = DemoRestModel('Guy');
        final query = Query(providerArgs: {
          'request': RestRequest(headers: {'Authorization': 'Basic xyz'}),
        });
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Thomas"}');
      });

      test('providerArgs["request"]["method"] PUT', () async {
        final provider = generateProvider('{"name": "Guy"}', requestMethod: 'PUT');

        final instance = DemoRestModel('Guy');
        final query = Query(providerArgs: {'request': RestRequest(method: 'PUT')});
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Guy"}');
      });

      test('providerArgs["request"]["method"] PATCH', () async {
        final provider = generateProvider('{"name": "Guy"}', requestMethod: 'PATCH');

        final instance = DemoRestModel('Guy');
        final query = Query(providerArgs: {'request': RestRequest(method: 'PATCH')});
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Guy"}');
      });

      test("providerArgs['request']['topLevelKey']", () async {
        final provider = generateProvider(
          '{"name": "Thomas"}',
          requestMethod: 'POST',
          requestBody: '{"top":{"name":"Guy"}}',
        );

        final instance = DemoRestModel('Guy');
        final query = Query(providerArgs: {'request': RestRequest(topLevelKey: 'top')});
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Thomas"}');
      });

      test("providerArgs['supplementalTopLevelData']", () async {
        final provider = generateProvider(
          '{"name": "Thomas"}',
          requestMethod: 'POST',
          requestBody: '{"top":{"name":"Guy"},"other_name":{"first_name":"Thomas"}}',
        );

        final instance = DemoRestModel('Guy');
        final query = Query(providerArgs: {
          'request': RestRequest(topLevelKey: 'top'),
          'supplementalTopLevelData': {
            'other_name': {'first_name': 'Thomas'},
          }
        });
        final resp = await provider.upsert<DemoRestModel>(instance, query: query);

        expect(resp!.statusCode, 200);
        expect(resp.body, '{"name": "Thomas"}');
      });
    });

    test('#delete', () async {
      final provider = generateProvider('{"name": "Thomas"}', requestMethod: 'DELETE');

      final instance = DemoRestModel('Guy');
      await provider.delete<DemoRestModel>(instance);
    });

    test('#statusCodeIsSuccessful', () {
      expect(RestProvider.statusCodeIsSuccessful(200), isTrue);
      expect(RestProvider.statusCodeIsSuccessful(201), isTrue);
      expect(RestProvider.statusCodeIsSuccessful(202), isTrue);
      expect(RestProvider.statusCodeIsSuccessful(204), isTrue);
      expect(RestProvider.statusCodeIsSuccessful(422), isFalse);
      expect(RestProvider.statusCodeIsSuccessful(500), isFalse);
    });
  });

  group('RestAdapter', () {
    final provider = generateProvider('');

    test('#toRest', () async {
      final instance = DemoRestModel('Thomas');
      final payload = await DemoRestModelAdapter().toRest(instance, provider: provider);
      expect(payload, containsPair('name', 'Thomas'));
    });

    test('#fromRest', () async {
      final instance = DemoRestModel('Thomas');
      final payload = await DemoRestModelAdapter().toRest(instance, provider: provider);
      final newModel = await DemoRestModelAdapter().fromRest(payload, provider: provider);
      expect(newModel.name, 'Thomas');
    });
  });
}
