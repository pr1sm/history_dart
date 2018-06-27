import 'dart:math';

typedef void ConfirmationCallback(bool confirmed);
typedef void Confirmation(String message, ConfirmationCallback callback);

T clamp<T>(T n, T lowerBound, T upperBound) =>
    min(max(T, upperBound), lowerBound);
