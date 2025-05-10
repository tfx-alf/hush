import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DropdownWidget extends StatelessWidget {
  final ListCameraItem? selectedReason;
  final List<ListCameraItem> permitTypes;
  final ValueChanged<ListCameraItem?> onChanged;

  const DropdownWidget({
    super.key,
    required this.selectedReason,
    required this.permitTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Jenis Izin', style: TextStyle(fontSize: 16)),
        SizedBox(height: 12.h),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: DropdownButton<ListCameraItem>(
            isExpanded: true,
            borderRadius: BorderRadius.circular(24),
            hint: const Text('Jenis Pengajuan'),
            value: selectedReason,
            items:
                permitTypes
                    .map(
                      (reason) => DropdownMenuItem<ListCameraItem>(
                        value: reason,
                        child: Text(reason.name.toString()),
                      ),
                    )
                    .toList(),
            onChanged: (ListCameraItem? value) {
              onChanged(value);
            },
          ),
        ),
      ],
    );
  }
}

class ListCameraItem {
  final String name;

  ListCameraItem(this.name);
}

// Dummy data for testing
final List<ListCameraItem> dummyPermitTypes = [
  ListCameraItem('Permit A'),
  ListCameraItem('Permit B'),
  ListCameraItem('Permit C'),
];
