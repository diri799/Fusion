import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/event_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../../data/models/common.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;
  
  const EditEventScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _eventTimeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  
  EventCategory _selectedCategory = EventCategory.technical;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _eventTimeController.dispose();
    _departmentController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _loadEventData() async {
    try {
      final eventProvider = context.read<EventProvider>();
      final event = await eventProvider.getEventById(widget.eventId);
      
      if (event != null) {
        setState(() {
          _titleController.text = event.title;
          _descriptionController.text = event.description;
          _venueController.text = event.venue ?? '';
          _eventTimeController.text = event.eventTime;
          _departmentController.text = event.department;
          _maxParticipantsController.text = event.maxParticipants.toString();
          _selectedCategory = event.category;
          _selectedDate = event.eventDate;
          _isInitialized = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event not found'),
              backgroundColor: Colors.red,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load event: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      _eventTimeController.text = time.format(context);
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final eventProvider = context.read<EventProvider>();
      final existingEvent = await eventProvider.getEventById(widget.eventId);
      
      if (existingEvent != null) {
        // Parse time from controller
        final timeText = _eventTimeController.text.trim();
        final timeParts = timeText.split(':');
        final hour = int.tryParse(timeParts[0]) ?? 9;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        final startDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          hour,
          minute,
        );
        final endDateTime = startDateTime.add(const Duration(hours: 2));
        
        final updatedEvent = existingEvent.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          venue: _venueController.text.trim().isEmpty ? null : _venueController.text.trim(),
          startDate: startDateTime,
          endDate: endDateTime,
          maxParticipants: int.tryParse(_maxParticipantsController.text),
          updatedAt: DateTime.now(),
        );
        
        final success = await eventProvider.updateEvent(updatedEvent);
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update event'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Edit Event',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const LoadingWidget(message: 'Loading event data...'),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Event',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateEvent,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update'),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Updating event...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleField(),
                    const SizedBox(height: 20),
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    _buildCategorySelector(),
                    const SizedBox(height: 20),
                    _buildVenueField(),
                    const SizedBox(height: 20),
                    _buildDateSelector(),
                    const SizedBox(height: 20),
                    _buildTimeSelector(),
                    const SizedBox(height: 20),
                    _buildDepartmentField(),
                    const SizedBox(height: 20),
                    _buildMaxParticipantsField(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Event Title',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter event title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 4,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter event description';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<EventCategory>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: EventCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildVenueField() {
    return TextFormField(
      controller: _venueController,
      decoration: const InputDecoration(
        labelText: 'Venue',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter venue';
        }
        return null;
      },
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return TextFormField(
      controller: _eventTimeController,
      decoration: const InputDecoration(
        labelText: 'Event Time',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.access_time),
      ),
      readOnly: true,
      onTap: _selectTime,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please select event time';
        }
        return null;
      },
    );
  }

  Widget _buildDepartmentField() {
    return TextFormField(
      controller: _departmentController,
      decoration: const InputDecoration(
        labelText: 'Department (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.school),
      ),
    );
  }

  Widget _buildMaxParticipantsField() {
    return TextFormField(
      controller: _maxParticipantsController,
      decoration: const InputDecoration(
        labelText: 'Max Participants (0 for unlimited)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.people),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = int.tryParse(value);
          if (number == null || number < 0) {
            return 'Please enter a valid number';
          }
        }
        return null;
      },
    );
  }
}