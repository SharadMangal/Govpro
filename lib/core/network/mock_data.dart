class MockData {
  static final List<Map<String, dynamic>> authorities = [
    {
      'id': 'a1111111-1111-1111-1111-111111111111',
      'name': 'NHAI',
      'logo_url': 'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=120&auto=format&fit=crop&q=60'
    },
    {
      'id': 'a2222222-2222-2222-2222-222222222222',
      'name': 'State PWD',
      'logo_url': 'https://images.unsplash.com/photo-1541872703-74c5e44368f9?w=120&auto=format&fit=crop&q=60'
    },
    {
      'id': 'a3333333-3333-3333-3333-333333333333',
      'name': 'PMGSY',
      'logo_url': 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=120&auto=format&fit=crop&q=60'
    }
  ];

  static final List<Map<String, dynamic>> contractors = [
    {
      'id': 'c1111111-1111-1111-1111-111111111111',
      'name': 'Green Path Constructions',
      'logo_url': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=120&auto=format&fit=crop&q=60'
    },
    {
      'id': 'c2222222-2222-2222-2222-222222222222',
      'name': 'Prime Structurals',
      'logo_url': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=120&auto=format&fit=crop&q=60'
    },
    {
      'id': 'c3333333-3333-3333-3333-333333333333',
      'name': 'Bharat Infra Ltd.',
      'logo_url': 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=120&auto=format&fit=crop&q=60'
    },
    {
      'id': 'c4444444-4444-4444-4444-444444444444',
      'name': 'Eastern Roads Co.',
      'logo_url': 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=120&auto=format&fit=crop&q=60'
    },
    {
      'id': 'c5555555-5555-5555-5555-555555555555',
      'name': 'Rural Build Pvt.',
      'logo_url': 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=120&auto=format&fit=crop&q=60'
    }
  ];

  static final List<Map<String, dynamic>> projects = [
    {
      'id': 'p0101010-1010-1010-1010-101010101010',
      'name': 'NH-114A Ranchi Bypass Widening',
      'district': 'Ranchi',
      'authority_id': 'a1111111-1111-1111-1111-111111111111',
      'contractor_id': 'c3333333-3333-3333-3333-333333333333',
      'status': 'in_progress',
      'completion_percent': 62.0,
      'budget': 3200000000.0, // ₹320 Cr
      'length_km': 42.5,
      'start_date': '2024-06-15',
      'end_date': '2026-01-20',
      'delay_days': 0,
      'site_photo_url': 'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?w=600&auto=format&fit=crop&q=80',
      'created_at': '2024-06-15T10:00:00Z',
      'updated_at': '2026-07-18T10:00:00Z'
    },
    {
      'id': 'p0202020-2020-2020-2020-202020202020',
      'name': 'SH-22 Dhanbad – Bokaro Corridor',
      'district': 'Dhanbad',
      'authority_id': 'a2222222-2222-2222-2222-222222222222',
      'contractor_id': 'c4444444-4444-4444-4444-444444444444',
      'status': 'delayed',
      'completion_percent': 35.0,
      'budget': 1800000000.0, // ₹180 Cr
      'length_km': 28.0,
      'start_date': '2025-01-10',
      'end_date': '2026-02-15',
      'delay_days': 12,
      'site_photo_url': 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=600&auto=format&fit=crop&q=80',
      'created_at': '2025-01-10T10:00:00Z',
      'updated_at': '2026-07-18T08:00:00Z'
    },
    {
      'id': 'p0303030-3030-3030-3030-303030303030',
      'name': 'MDR-08 Jamshedpur Rural Link',
      'district': 'East Singhbhum',
      'authority_id': 'a3333333-3333-3333-3333-333333333333',
      'contractor_id': 'c1111111-1111-1111-1111-111111111111',
      'status': 'completed',
      'completion_percent': 100.0,
      'budget': 450000000.0, // ₹45 Cr
      'length_km': 15.0,
      'start_date': '2024-06-01',
      'end_date': '2025-09-30',
      'delay_days': 0,
      'site_photo_url': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600&auto=format&fit=crop&q=80',
      'created_at': '2024-06-01T09:00:00Z',
      'updated_at': '2025-09-30T12:00:00Z'
    },
    {
      'id': 'p0404040-4040-4040-4040-404040404040',
      'name': 'SH-09 Palamu Widening Phase-II',
      'district': 'Palamu',
      'authority_id': 'a2222222-2222-2222-2222-222222222222',
      'contractor_id': 'c3333333-3333-3333-3333-333333333333',
      'status': 'in_progress',
      'completion_percent': 48.0,
      'budget': 1200000000.0, // ₹120 Cr
      'length_km': 32.0,
      'start_date': '2025-02-15',
      'end_date': '2026-03-31',
      'delay_days': 0,
      'site_photo_url': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&auto=format&fit=crop&q=80',
      'created_at': '2025-02-15T08:00:00Z',
      'updated_at': '2026-07-16T15:00:00Z'
    },
    {
      'id': 'p0505050-5050-5050-5050-505050505050',
      'name': 'MDR-14 Giridih Village Road',
      'district': 'Giridih',
      'authority_id': 'a3333333-3333-3333-3333-333333333333',
      'contractor_id': 'c5555555-5555-5555-5555-555555555555',
      'status': 'delayed',
      'completion_percent': 22.0,
      'budget': 250000000.0, // ₹25 Cr
      'length_km': 18.0,
      'start_date': '2025-04-10',
      'end_date': '2026-05-20',
      'delay_days': 18,
      'site_photo_url': 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=600&auto=format&fit=crop&q=80',
      'created_at': '2025-04-10T11:00:00Z',
      'updated_at': '2026-07-14T09:00:00Z'
    },
    {
      'id': 'p0606060-6060-6060-6060-606060606060',
      'name': 'NH-33 Hazaribagh Flyover',
      'district': 'Hazaribagh',
      'authority_id': 'a1111111-1111-1111-1111-111111111111',
      'contractor_id': 'c2222222-2222-2222-2222-222222222222',
      'status': 'in_progress',
      'completion_percent': 78.0,
      'budget': 1500000000.0, // ₹150 Cr
      'length_km': 8.5,
      'start_date': '2024-11-01',
      'end_date': '2026-01-30',
      'delay_days': 0,
      'site_photo_url': 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?w=600&auto=format&fit=crop&q=80',
      'created_at': '2024-11-01T10:00:00Z',
      'updated_at': '2026-07-18T10:00:00Z'
    }
  ];

  static final List<Map<String, dynamic>> stages = [
    // p01 stages
    {'id': 's01', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'stage_name': 'Land Acquisition & Clearance', 'sequence_order': 1, 'completion_percent': 100.0, 'start_date': '2024-06-15', 'end_date': '2024-09-10'},
    {'id': 's02', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'stage_name': 'Foundation & Earthwork', 'sequence_order': 2, 'completion_percent': 100.0, 'start_date': '2024-09-11', 'end_date': '2025-01-15'},
    {'id': 's03', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'stage_name': 'Base Layer Subgrade', 'sequence_order': 3, 'completion_percent': 80.0, 'start_date': '2025-01-16', 'end_date': null},
    {'id': 's04', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'stage_name': 'Paving & Bitumen Layering', 'sequence_order': 4, 'completion_percent': 10.0, 'start_date': '2025-06-01', 'end_date': null},
    {'id': 's05', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'stage_name': 'Signage & Safety Handover', 'sequence_order': 5, 'completion_percent': 0.0, 'start_date': '2025-11-01', 'end_date': null},

    // p02 stages
    {'id': 's06', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'stage_name': 'Land Acquisition & Clearance', 'sequence_order': 1, 'completion_percent': 100.0, 'start_date': '2025-01-10', 'end_date': '2025-04-20'},
    {'id': 's07', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'stage_name': 'Foundation work', 'sequence_order': 2, 'completion_percent': 60.0, 'start_date': '2025-04-21', 'end_date': null},
    {'id': 's08', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'stage_name': 'Base Layer Subgrade', 'sequence_order': 3, 'completion_percent': 10.0, 'start_date': '2025-09-01', 'end_date': null},
    {'id': 's09', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'stage_name': 'Paving & Bitumen Layering', 'sequence_order': 4, 'completion_percent': 0.0, 'start_date': '2025-12-10', 'end_date': null},
    {'id': 's10', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'stage_name': 'Signage & Safety Handover', 'sequence_order': 5, 'completion_percent': 0.0, 'start_date': '2026-01-20', 'end_date': null},

    // p03 stages
    {'id': 's11', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'stage_name': 'Land Acquisition & Clearance', 'sequence_order': 1, 'completion_percent': 100.0, 'start_date': '2024-06-01', 'end_date': '2024-08-10'},
    {'id': 's12', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'stage_name': 'Foundation work', 'sequence_order': 2, 'completion_percent': 100.0, 'start_date': '2024-08-11', 'end_date': '2024-12-20'},
    {'id': 's13', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'stage_name': 'Base Layer Subgrade', 'sequence_order': 3, 'completion_percent': 100.0, 'start_date': '2024-12-21', 'end_date': '2025-04-15'},
    {'id': 's14', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'stage_name': 'Paving & Bitumen Layering', 'sequence_order': 4, 'completion_percent': 100.0, 'start_date': '2025-04-16', 'end_date': '2025-08-30'},
    {'id': 's15', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'stage_name': 'Signage & Safety Handover', 'sequence_order': 5, 'completion_percent': 100.0, 'start_date': '2025-09-01', 'end_date': '2025-09-30'},

    // p04 stages
    {'id': 's16', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'stage_name': 'Land Acquisition & Clearance', 'sequence_order': 1, 'completion_percent': 100.0, 'start_date': '2025-02-15', 'end_date': '2025-05-10'},
    {'id': 's17', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'stage_name': 'Foundation work', 'sequence_order': 2, 'completion_percent': 90.0, 'start_date': '2025-05-11', 'end_date': null},
    {'id': 's18', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'stage_name': 'Base Layer Subgrade', 'sequence_order': 3, 'completion_percent': 40.0, 'start_date': '2025-09-01', 'end_date': null},
    {'id': 's19', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'stage_name': 'Paving & Bitumen Layering', 'sequence_order': 4, 'completion_percent': 0.0, 'start_date': '2026-01-10', 'end_date': null},
    {'id': 's20', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'stage_name': 'Signage & Safety Handover', 'sequence_order': 5, 'completion_percent': 0.0, 'start_date': '2026-03-01', 'end_date': null},

    // p05 stages
    {'id': 's21', 'project_id': 'p0505050-5050-5050-5050-505050505050', 'stage_name': 'Land Acquisition & Clearance', 'sequence_order': 1, 'completion_percent': 80.0, 'start_date': '2025-04-10', 'end_date': null},
    {'id': 's22', 'project_id': 'p0505050-5050-5050-5050-505050505050', 'stage_name': 'Foundation work', 'sequence_order': 2, 'completion_percent': 20.0, 'start_date': '2025-08-01', 'end_date': null},
    {'id': 's23', 'project_id': 'p0505050-5050-5050-5050-505050505050', 'stage_name': 'Base Layer Subgrade', 'sequence_order': 3, 'completion_percent': 0.0, 'start_date': '2025-12-01', 'end_date': null},
    {'id': 's24', 'project_id': 'p0505050-5050-5050-5050-505050505050', 'stage_name': 'Paving & Bitumen Layering', 'sequence_order': 4, 'completion_percent': 0.0, 'start_date': '2026-03-01', 'end_date': null},
    {'id': 's25', 'project_id': 'p0505050-5050-5050-5050-505050505050', 'stage_name': 'Signage & Safety Handover', 'sequence_order': 5, 'completion_percent': 0.0, 'start_date': '2026-05-01', 'end_date': null},

    // p06 stages
    {'id': 's26', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'stage_name': 'Land Acquisition & Clearance', 'sequence_order': 1, 'completion_percent': 100.0, 'start_date': '2024-11-01', 'end_date': '2024-12-30'},
    {'id': 's27', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'stage_name': 'Foundation work & Pillars', 'sequence_order': 2, 'completion_percent': 100.0, 'start_date': '2025-01-01', 'end_date': '2025-04-15'},
    {'id': 's28', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'stage_name': 'Base Layer Subgrade', 'sequence_order': 3, 'completion_percent': 90.0, 'start_date': '2025-04-16', 'end_date': null},
    {'id': 's29', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'stage_name': 'Paving & Bitumen Layering', 'sequence_order': 4, 'completion_percent': 60.0, 'start_date': '2025-08-01', 'end_date': null},
    {'id': 's30', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'stage_name': 'Signage & Safety Handover', 'sequence_order': 5, 'completion_percent': 0.0, 'start_date': '2025-12-01', 'end_date': null}
  ];

  static final List<Map<String, dynamic>> materials = [
    // p01
    {'id': 'm01', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'material_name': 'Bitumen', 'quantity': 3200.0, 'unit': 'tonnes'},
    {'id': 'm02', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'material_name': 'Cement (OPC 53)', 'quantity': 10500.0, 'unit': 'bags'},
    {'id': 'm03', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'material_name': 'Crushed Aggregates', 'quantity': 28000.0, 'unit': 'cubic meters'},
    {'id': 'm04', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'material_name': 'Reinforced Steel (TMT)', 'quantity': 1200.0, 'unit': 'tonnes'},

    // p02
    {'id': 'm05', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'material_name': 'Bitumen', 'quantity': 1800.0, 'unit': 'tonnes'},
    {'id': 'm06', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'material_name': 'Cement', 'quantity': 8000.0, 'unit': 'bags'},
    {'id': 'm07', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'material_name': 'Crushed Aggregates', 'quantity': 16000.0, 'unit': 'cubic meters'},

    // p03
    {'id': 'm08', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'material_name': 'Bitumen', 'quantity': 1100.0, 'unit': 'tonnes'},
    {'id': 'm09', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'material_name': 'Cement', 'quantity': 4500.0, 'unit': 'bags'},
    {'id': 'm10', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'material_name': 'Crushed Aggregates', 'quantity': 9000.0, 'unit': 'cubic meters'},

    // p04
    {'id': 'm11', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'material_name': 'Bitumen', 'quantity': 2100.0, 'unit': 'tonnes'},
    {'id': 'm12', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'material_name': 'Cement', 'quantity': 7200.0, 'unit': 'bags'},

    // p05
    {'id': 'm13', 'project_id': 'p0505050-5050-5050-5050-505050505050', 'material_name': 'Cement', 'quantity': 1500.0, 'unit': 'bags'},
    {'id': 'm14', 'project_id': 'p0505050-5050-5050-5050-505050505050', 'material_name': 'Gravel aggregates', 'quantity': 4500.0, 'unit': 'cubic meters'},

    // p06
    {'id': 'm15', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'material_name': 'Structural Steel', 'quantity': 800.0, 'unit': 'tonnes'},
    {'id': 'm16', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'material_name': 'Bitumen', 'quantity': 950.0, 'unit': 'tonnes'}
  ];

  static final List<Map<String, dynamic>> monthlyProgress = [
    // p01 progress
    {'id': 'mp01', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'month': '2026-01-01', 'completion_percent': 40.0},
    {'id': 'mp02', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'month': '2026-02-01', 'completion_percent': 45.0},
    {'id': 'mp03', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'month': '2026-03-01', 'completion_percent': 50.0},
    {'id': 'mp04', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'month': '2026-04-01', 'completion_percent': 52.0},
    {'id': 'mp05', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'month': '2026-05-01', 'completion_percent': 58.0},
    {'id': 'mp06', 'project_id': 'p0101010-1010-1010-1010-101010101010', 'month': '2026-06-01', 'completion_percent': 62.0},

    // p02 progress
    {'id': 'mp07', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'month': '2026-01-01', 'completion_percent': 28.0},
    {'id': 'mp08', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'month': '2026-02-01', 'completion_percent': 30.0},
    {'id': 'mp09', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'month': '2026-03-01', 'completion_percent': 32.0},
    {'id': 'mp10', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'month': '2026-04-01', 'completion_percent': 32.0},
    {'id': 'mp11', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'month': '2026-05-01', 'completion_percent': 35.0},
    {'id': 'mp12', 'project_id': 'p0202020-2020-2020-2020-202020202020', 'month': '2026-06-01', 'completion_percent': 35.0},

    // p03 progress
    {'id': 'mp13', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'month': '2026-01-01', 'completion_percent': 80.0},
    {'id': 'mp14', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'month': '2026-02-01', 'completion_percent': 85.0},
    {'id': 'mp15', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'month': '2026-03-01', 'completion_percent': 90.0},
    {'id': 'mp16', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'month': '2026-04-01', 'completion_percent': 95.0},
    {'id': 'mp17', 'project_id': 'p0303030-3030-3030-3030-303030303030', 'month': '2026-05-01', 'completion_percent': 100.0},

    // p04 progress
    {'id': 'mp18', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'month': '2026-01-01', 'completion_percent': 30.0},
    {'id': 'mp19', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'month': '2026-02-01', 'completion_percent': 35.0},
    {'id': 'mp20', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'month': '2026-03-01', 'completion_percent': 40.0},
    {'id': 'mp21', 'project_id': 'p0404040-4040-4040-4040-404040404040', 'month': '2026-04-01', 'completion_percent': 48.0},

    // p05 progress
    {'id': 'mp22', 'project_id': 'p0505050-5050-5050-5050-505050505050', 'month': '2026-01-01', 'completion_percent': 10.0},
    {'id': 'mp23', 'project_id': 'p0505050-5050-5050-5050-505050505050', 'month': '2026-02-01', 'completion_percent': 15.0},
    {'id': 'mp24', 'project_id': 'p0505050-5050-5050-5050-505050505050', 'month': '2026-03-01', 'completion_percent': 22.0},

    // p06 progress
    {'id': 'mp25', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'month': '2026-01-01', 'completion_percent': 50.0},
    {'id': 'mp26', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'month': '2026-02-01', 'completion_percent': 60.0},
    {'id': 'mp27', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'month': '2026-03-01', 'completion_percent': 70.0},
    {'id': 'mp28', 'project_id': 'p0606060-6060-6060-6060-606060606060', 'month': '2026-04-01', 'completion_percent': 78.0}
  ];

  static final List<Map<String, dynamic>> notifications = [
    {
      'id': 'n01',
      'project_id': 'p0202020-2020-2020-2020-202020202020',
      'title': 'Delay reported',
      'message': 'Heavy rain halted foundation work for 3 days.',
      'is_read': false,
      'created_at': '2026-07-18T16:54:00Z' // 12m ago
    },
    {
      'id': 'n02',
      'project_id': 'p0101010-1010-1010-1010-101010101010',
      'title': 'Milestone reached',
      'message': 'Base Layer crossed 60% completion.',
      'is_read': false,
      'created_at': '2026-07-18T16:06:00Z' // 1h ago
    },
    {
      'id': 'n03',
      'project_id': 'p0606060-6060-6060-6060-606060606060',
      'title': 'Inspection scheduled',
      'message': 'Site inspection on 22 July by Chief Engineer.',
      'is_read': false,
      'created_at': '2026-07-18T13:06:00Z' // 4h ago
    },
    {
      'id': 'n04',
      'project_id': 'p0303030-3030-3030-3030-303030303030',
      'title': 'Project completed',
      'message': 'Handover documents submitted.',
      'is_read': true,
      'created_at': '2026-07-17T17:06:00Z' // 1d ago
    },
    {
      'id': 'n05',
      'project_id': 'p0505050-5050-5050-5050-505050505050',
      'title': 'Land acquisition update',
      'message': 'Revenue dept. escalated to district collector.',
      'is_read': true,
      'created_at': '2026-07-16T17:06:00Z' // 2d ago
    },
    {
      'id': 'n06',
      'project_id': 'p0404040-4040-4040-4040-404040404040',
      'title': 'Material delivery',
      'message': '1,200T bitumen delivered on-site.',
      'is_read': true,
      'created_at': '2026-07-15T17:06:00Z' // 3d ago
    }
  ];

  static List<Map<String, dynamic>> getInitialMonthlyProgressForOtherProjects() {
    List<Map<String, dynamic>> res = [];
    int counter = 25;
    for (var proj in projects) {
      String pid = proj['id'];
      if (pid == 'p0101010-1010-1010-1010-101010101010' ||
          pid == 'p0202020-2020-2020-2020-202020202020' ||
          pid == 'p0303030-3030-3030-3030-303030303030' ||
          pid == 'p0404040-4040-4040-4040-404040404040') {
        continue;
      }
      double currentPercent = proj['completion_percent'];
      res.add({'id': 'mp$counter', 'project_id': pid, 'month': '2026-01-01', 'completion_percent': (currentPercent - 25).clamp(0.0, 100.0)});
      res.add({'id': 'mp${counter+1}', 'project_id': pid, 'month': '2026-02-01', 'completion_percent': (currentPercent - 20).clamp(0.0, 100.0)});
      res.add({'id': 'mp${counter+2}', 'project_id': pid, 'month': '2026-03-01', 'completion_percent': (currentPercent - 15).clamp(0.0, 100.0)});
      res.add({'id': 'mp${counter+3}', 'project_id': pid, 'month': '2026-04-01', 'completion_percent': (currentPercent - 10).clamp(0.0, 100.0)});
      res.add({'id': 'mp${counter+4}', 'project_id': pid, 'month': '2026-05-01', 'completion_percent': (currentPercent - 5).clamp(0.0, 100.0)});
      res.add({'id': 'mp${counter+5}', 'project_id': pid, 'month': '2026-06-01', 'completion_percent': currentPercent});
      counter += 6;
    }
    return res;
  }

  static List<Map<String, dynamic>> getInitialStagesForOtherProjects() {
    List<Map<String, dynamic>> res = [];
    int counter = 21;
    for (var proj in projects) {
      String pid = proj['id'];
      if (pid == 'p0101010-1010-1010-1010-101010101010' ||
          pid == 'p0202020-2020-2020-2020-202020202020' ||
          pid == 'p0303030-3030-3030-3030-303030303030' ||
          pid == 'p0404040-4040-4040-4040-404040404040') {
        continue;
      }
      String status = proj['status'];
      res.add({
        'id': 's$counter',
        'project_id': pid,
        'stage_name': 'Initial Preparation & Mobilization',
        'sequence_order': 1,
        'completion_percent': 100.0,
        'start_date': proj['start_date'],
        'end_date': proj['start_date'],
      });
      res.add({
        'id': 's${counter+1}',
        'project_id': pid,
        'stage_name': 'Subgrade & Earthwork Foundation',
        'sequence_order': 2,
        'completion_percent': status == 'completed' ? 100.0 : (status == 'delayed' ? 40.0 : 60.0),
        'start_date': proj['start_date'],
        'end_date': status == 'completed' ? proj['end_date'] : null,
      });
      res.add({
        'id': 's${counter+2}',
        'project_id': pid,
        'stage_name': 'Major Paving & Asphalt Layering',
        'sequence_order': 3,
        'completion_percent': status == 'completed' ? 100.0 : 0.0,
        'start_date': proj['start_date'],
        'end_date': status == 'completed' ? proj['end_date'] : null,
      });
      counter += 3;
    }
    return res;
  }
}
