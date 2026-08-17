import 'package:flutter/material.dart';

class IconMapper {
  IconMapper._();

  static IconData getIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    
    if (lowerName.contains('electrician')) return Icons.electrical_services;
    if (lowerName.contains('plumber')) return Icons.plumbing;
    if (lowerName.contains('mechanic')) return Icons.build;
    if (lowerName.contains('carpenter')) return Icons.carpenter;
    if (lowerName.contains('painter')) return Icons.format_paint;
    if (lowerName.contains('cleaning') || lowerName.contains('maid')) return Icons.cleaning_services;
    if (lowerName.contains('driver')) return Icons.directions_car;
    if (lowerName.contains('cook') || lowerName.contains('chef')) return Icons.restaurant;
    if (lowerName.contains('tailor')) return Icons.cut;
    if (lowerName.contains('gardener')) return Icons.yard;
    if (lowerName.contains('pest')) return Icons.pest_control;
    if (lowerName.contains('ac') || lowerName.contains('appliance')) return Icons.ac_unit;
    if (lowerName.contains('rent') || lowerName.contains('house')) return Icons.house;
    if (lowerName.contains('tuition') || lowerName.contains('tutor') || lowerName.contains('teacher')) return Icons.school;
    if (lowerName.contains('salon') || lowerName.contains('beauty')) return Icons.face_retouching_natural;
    if (lowerName.contains('massage')) return Icons.spa;
    if (lowerName.contains('fitness') || lowerName.contains('trainer')) return Icons.fitness_center;
    if (lowerName.contains('photographer')) return Icons.camera_alt;
    if (lowerName.contains('event')) return Icons.event;
    if (lowerName.contains('packers') || lowerName.contains('movers')) return Icons.local_shipping;
    if (lowerName.contains('security')) return Icons.security;
    
    return Icons.design_services;
  }
}
