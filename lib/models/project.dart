import 'authority.dart';
import 'contractor.dart';

class Project {
  final String id;
  final String name;
  final String district;
  final String authorityId;
  final String contractorId;
  final String status; // 'completed', 'in_progress', 'delayed'
  final double completionPercent;
  final double budget;
  final double lengthKm;
  final DateTime startDate;
  final DateTime endDate;
  final int delayDays;
  final String? sitePhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined relations (optional)
  final Authority? authority;
  final Contractor? contractor;

  Project({
    required this.id,
    required this.name,
    required this.district,
    required this.authorityId,
    required this.contractorId,
    required this.status,
    required this.completionPercent,
    required this.budget,
    required this.lengthKm,
    required this.startDate,
    required this.endDate,
    required this.delayDays,
    this.sitePhotoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.authority,
    this.contractor,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    // Parse Joined Authority
    Authority? parsedAuthority;
    if (json['authorities'] != null) {
      parsedAuthority = Authority.fromJson(json['authorities'] as Map<String, dynamic>);
    } else if (json['authority'] != null) {
      parsedAuthority = Authority.fromJson(json['authority'] as Map<String, dynamic>);
    }

    // Parse Joined Contractor
    Contractor? parsedContractor;
    if (json['contractors'] != null) {
      parsedContractor = Contractor.fromJson(json['contractors'] as Map<String, dynamic>);
    } else if (json['contractor'] != null) {
      parsedContractor = Contractor.fromJson(json['contractor'] as Map<String, dynamic>);
    }

    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      district: json['district'] as String,
      authorityId: json['authority_id'] as String,
      contractorId: json['contractor_id'] as String,
      status: json['status'] as String,
      completionPercent: (json['completion_percent'] as num?)?.toDouble() ?? 0.0,
      budget: (json['budget'] as num).toDouble(),
      lengthKm: (json['length_km'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      delayDays: json['delay_days'] as int? ?? 0,
      sitePhotoUrl: json['site_photo_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : DateTime.now(),
      authority: parsedAuthority,
      contractor: parsedContractor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'authority_id': authorityId,
      'contractor_id': contractorId,
      'status': status,
      'completion_percent': completionPercent,
      'budget': budget,
      'length_km': lengthKm,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'delay_days': delayDays,
      'site_photo_url': sitePhotoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (authority != null) 'authorities': authority!.toJson(),
      if (contractor != null) 'contractors': contractor!.toJson(),
    };
  }

  Project copyWith({
    String? id,
    String? name,
    String? district,
    String? authorityId,
    String? contractorId,
    String? status,
    double? completionPercent,
    double? budget,
    double? lengthKm,
    DateTime? startDate,
    DateTime? endDate,
    int? delayDays,
    String? sitePhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Authority? authority,
    Contractor? contractor,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      district: district ?? this.district,
      authorityId: authorityId ?? this.authorityId,
      contractorId: contractorId ?? this.contractorId,
      status: status ?? this.status,
      completionPercent: completionPercent ?? this.completionPercent,
      budget: budget ?? this.budget,
      lengthKm: lengthKm ?? this.lengthKm,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      delayDays: delayDays ?? this.delayDays,
      sitePhotoUrl: sitePhotoUrl ?? this.sitePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authority: authority ?? this.authority,
      contractor: contractor ?? this.contractor,
    );
  }
}
