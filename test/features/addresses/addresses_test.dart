import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/features/addresses/application/addresses_controller.dart';
import 'package:chimbo/features/addresses/data/address_repository.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/addresses/presentation/address_form_screen.dart';
import 'package:chimbo/features/addresses/presentation/addresses_screen.dart';
import 'package:chimbo/features/locations/data/location_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/fake_location_repository.dart';

void main() {
  testWidgets('shows the default address first', (tester) async {
    final repository = _MemoryAddressRepository([
      _address(2, 'Asha Mussa', isDefault: false),
      _address(1, 'Joyce Joseph', isDefault: true),
    ]);
    await _pumpAddresses(tester, repository);

    expect(find.text('Joyce Joseph'), findsOneWidget);
    expect(find.text('Asha Mussa'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Joyce Joseph')).dy,
      lessThan(tester.getTopLeft(find.text('Asha Mussa')).dy),
    );
    expect(find.text('Chaguo-msingi'), findsOneWidget);
  });

  testWidgets('edits an address using the shared address form', (tester) async {
    final repository = _MemoryAddressRepository([
      _address(1, 'Joyce Joseph', isDefault: true),
    ]);
    await _pumpAddresses(tester, repository);

    await tester.tap(find.byKey(const ValueKey('address-menu-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hariri'));
    await tester.pumpAndSettle();

    expect(find.text('Hariri Anwani'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Jina la mpokeaji'),
      'Asha Mussa',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mtaa / eneo'),
      'Kariakoo mpya',
    );
    await tester.tap(find.text('Hifadhi anwani'));
    await tester.pumpAndSettle();

    expect(repository.addresses.single.recipientName, 'Asha Mussa');
    expect(repository.addresses.single.street, 'Kariakoo mpya');
    expect(find.text('Asha Mussa'), findsOneWidget);
  });

  testWidgets('makes an address default', (tester) async {
    final repository = _MemoryAddressRepository([
      _address(1, 'Joyce Joseph', isDefault: true),
      _address(2, 'Asha Mussa', isDefault: false),
    ]);
    await _pumpAddresses(tester, repository);

    await tester.tap(find.byKey(const ValueKey('address-menu-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fanya chaguo-msingi'));
    await tester.pumpAndSettle();

    expect(repository.addresses.first.id, 2);
    expect(repository.addresses.first.isDefault, isTrue);
    expect(find.text('Chaguo-msingi'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Asha Mussa')).dy,
      lessThan(tester.getTopLeft(find.text('Joyce Joseph')).dy),
    );
  });

  testWidgets('deletes only after confirmation', (tester) async {
    final repository = _MemoryAddressRepository([
      _address(1, 'Joyce Joseph', isDefault: true),
      _address(2, 'Asha Mussa', isDefault: false),
    ]);
    await _pumpAddresses(tester, repository);

    await tester.tap(find.byKey(const ValueKey('address-menu-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Futa'));
    await tester.pumpAndSettle();

    expect(find.text('Futa anwani?'), findsOneWidget);
    await tester.tap(find.text('Ghairi'));
    await tester.pumpAndSettle();
    expect(repository.addresses, hasLength(2));

    await tester.tap(find.byKey(const ValueKey('address-menu-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Futa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Futa'));
    await tester.pumpAndSettle();

    expect(repository.addresses, hasLength(1));
    expect(repository.addresses.single.recipientName, 'Asha Mussa');
    expect(repository.addresses.single.isDefault, isTrue);
  });
}

Future<void> _pumpAddresses(
  WidgetTester tester,
  _MemoryAddressRepository repository,
) async {
  final router = GoRouter(
    initialLocation: AppRoutes.profileAddresses,
    routes: [
      GoRoute(
        path: AppRoutes.profileAddresses,
        builder: (context, state) => const AddressesScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddressFormScreen(),
          ),
          GoRoute(
            path: ':addressId/edit',
            builder: (context, state) =>
                AddressFormScreen(address: state.extra! as Address),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        addressRepositoryProvider.overrideWithValue(repository),
        addressesControllerProvider.overrideWith(_TestAddressesController.new),
        locationRepositoryProvider.overrideWithValue(
          const FakeLocationRepository(),
        ),
      ],
      child: MaterialApp.router(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _TestAddressesController extends AddressesController {
  @override
  Future<List<Address>> build() async {
    final addresses = await ref.read(addressRepositoryProvider).getAddresses();
    return [
      ...addresses.where((address) => address.isDefault),
      ...addresses.where((address) => !address.isDefault),
    ];
  }
}

class _MemoryAddressRepository implements AddressRepository {
  _MemoryAddressRepository(List<Address> initialAddresses)
    : addresses = [...initialAddresses];

  List<Address> addresses;

  @override
  Future<List<Address>> getAddresses() async => [...addresses];

  @override
  Future<Address> createAddress(AddressInput input) async {
    final address = _fromInput(addresses.length + 1, input);
    addresses = [...addresses, address];
    return address;
  }

  @override
  Future<Address> updateAddress(int addressId, AddressInput input) async {
    final previous = addresses.firstWhere((item) => item.id == addressId);
    final updated = _fromInput(addressId, input, isDefault: previous.isDefault);
    addresses = [
      for (final address in addresses)
        if (address.id == addressId) updated else address,
    ];
    return updated;
  }

  @override
  Future<List<Address>> setDefaultAddress(int addressId) async {
    addresses = _sortDefaultFirst([
      for (final address in addresses)
        _copyAddress(address, isDefault: address.id == addressId),
    ]);
    return [...addresses];
  }

  @override
  Future<List<Address>> deleteAddress(int addressId) async {
    final removed = addresses.firstWhere((item) => item.id == addressId);
    addresses = addresses.where((item) => item.id != addressId).toList();
    if (removed.isDefault && addresses.isNotEmpty) {
      final newest = addresses.reduce(
        (current, address) => address.id > current.id ? address : current,
      );
      addresses = _sortDefaultFirst([
        for (final address in addresses)
          _copyAddress(address, isDefault: address.id == newest.id),
      ]);
    }
    return [...addresses];
  }

  List<Address> _sortDefaultFirst(List<Address> values) => [
    ...values.where((address) => address.isDefault),
    ...values.where((address) => !address.isDefault),
  ];

  Address _fromInput(int id, AddressInput input, {bool isDefault = false}) =>
      Address(
        id: id,
        recipientName: input.recipientName,
        phone: input.phone,
        regionId: input.regionId,
        regionName: 'Dar es Salaam',
        districtId: input.districtId,
        districtName: input.districtId == null ? null : 'Ilala',
        street: input.street,
        landmark: input.landmark,
        isDefault: isDefault,
      );
}

Address _copyAddress(Address address, {required bool isDefault}) => Address(
  id: address.id,
  recipientName: address.recipientName,
  phone: address.phone,
  regionId: address.regionId,
  regionName: address.regionName,
  districtId: address.districtId,
  districtName: address.districtName,
  street: address.street,
  landmark: address.landmark,
  isDefault: isDefault,
);

Address _address(int id, String recipientName, {required bool isDefault}) =>
    Address(
      id: id,
      recipientName: recipientName,
      phone: '+255712345678',
      regionId: 1,
      regionName: 'Dar es Salaam',
      districtId: 1,
      districtName: 'Ilala',
      street: 'Kariakoo',
      landmark: 'Soko Kuu',
      isDefault: isDefault,
    );
