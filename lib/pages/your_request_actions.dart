import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/models/your_request_model.dart';
import 'package:serbisyo_mobileapp/pages/service_category_page.dart';
import 'package:serbisyo_mobileapp/services/your_requests_service.dart';

class YourRequestActions {
  const YourRequestActions({required YourRequestsService service})
    : _service = service;

  final YourRequestsService _service;

  void bookAgain(BuildContext context, YourRequestModel request) {
    final match = _service.findServiceForBookAgain(request.title);
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service not found for this request')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceCategoryPage(
          title: match.title,
          services: match.services,
          initialSelectedIndex: match.selectedIndex,
        ),
      ),
    );
  }

  Future<bool> confirmCancelRequest(
    BuildContext context, {
    required Color promptBlue,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/Penguin_promot_icon.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 14),
              const Text(
                'Are you sure you want to cancel this request?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff7C7979),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff254356),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: promptBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  Future<void> cancelUserRequest(
    BuildContext context, {
    required String requestId,
    required Color promptBlue,
  }) async {
    final ok = await confirmCancelRequest(context, promptBlue: promptBlue);
    if (!ok) return;

    try {
      await _service.cancelRequest(requestId: requestId);
    } catch (_) {
      // Keep UX silent here; request list will refresh via stream.
    }
  }

  Future<void> showRateProviderDialog({
    required BuildContext context,
    required String requestId,
    required String providerId,
    required String providerName,
  }) async {
    final commentController = TextEditingController();

    var selectedRating = 0;
    var isSubmitting = false;

    Future<void> submit(StateSetter setState) async {
      if (selectedRating <= 0 || isSubmitting) return;
      setState(() => isSubmitting = true);

      try {
        await _service.submitProviderRating(
          requestId: requestId,
          providerId: providerId,
          rating: selectedRating.toDouble(),
          comment: commentController.text.trim(),
        );

        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks! Your review was submitted.')),
        );
      } on StateError catch (e) {
        if (!context.mounted) return;
        if (e.message == 'already-rated') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You already rated this provider.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit review')),
          );
        }
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review')),
        );
      } finally {
        if (context.mounted) {
          setState(() => isSubmitting = false);
        }
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            Widget star(int index) {
              final filled = selectedRating >= index;
              return IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                onPressed: isSubmitting
                    ? null
                    : () => setState(() => selectedRating = index),
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: const Color(0xffF2C94C),
                ),
              );
            }

            return AlertDialog(
              title: Text('Rate $providerName'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [star(1), star(2), star(3), star(4), star(5)],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Comment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: commentController,
                      enabled: !isSubmitting,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Add a short comment…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (selectedRating > 0 && !isSubmitting)
                      ? () => submit(setState)
                      : null,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
